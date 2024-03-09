import os
import os.path
import time
from abcli import env, file
from abcli import path
from abcli import env
from abcli import string
from abcli.logger import logger, crash_report


class Storage:
    def __init__(self, bucket_name=env.abcli_aws_s3_bucket_name):
        self.region = env.abcli_aws_region

        try:
            import boto3

            self.s3 = boto3.client("s3", region_name=self.region)
        except:
            crash_report("-storage: failed.")

        self.bucket_name = bucket_name

        self.create_bucket()

    def create_bucket(self, bucket_name=None):
        """create bucket.

        Args:
            bucket_name (str, optional): bucket name. Defaults to None.

        Returns:
            bool: success.
        """
        if bucket_name is None:
            bucket_name = self.bucket_name

        try:
            import boto3

            if boto3.resource("s3").Bucket(bucket_name).creation_date is not None:
                logger.debug(f"-storage: create_bucket: {bucket_name}: already exists.")
                return True

            self.s3.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={"LocationConstraint": self.region},
            )
        except:
            crash_report(f"-storage: create_bucket: {bucket_name}: failed.")
            return False

        return True

    def download_file(
        self,
        object_name,
        filename="",
        bucket_name=None,
        civilized=False,
        log=True,
        overwrite=False,
    ):
        """download file.

        Args:
            object_name (str): object name.
            filename (str, optional): filename to download. Defaults to "".
            bucket_name (str, optional): bucket name. Default to None.
            civilized (bool, optional): if failed, do not print error message. Defaults to False.
            log (bool, optional): log. Default to False.
            overwrite (bool, optional): overwrite filename. Defaults to False.

        Returns:
            bool: success
        """
        if filename == "static":
            filename = os.path.join(
                env.abcli_path_static,
                object_name.replace("/", "-"),
            )

        if filename == "object":
            filename = os.path.join(
                env.abcli_object_root,
                "/".join(object_name.split("/")[1:]),
            )

        if not overwrite and file.exist(filename):
            return True

        if not path.create(file.path(filename)):
            return False

        if bucket_name is None:
            bucket_name = self.bucket_name

        success = False
        try:
            self.s3.download_file(bucket_name, object_name, filename)
            success = True
        except:
            if not civilized:
                crash_report(
                    f"-storage: download_file({bucket_name}/{object_name}): failed."
                )

        if success and log:
            logger.info(f"downloaded {bucket_name}/{object_name} -> {filename}")

        return success

    def list_of_objects(
        self,
        prefix,
        bucket_name=None,
        count=-1,
        postfix="",
        recursive=True,
        include_folders=False,
    ):
        """list objects.

        Args:
            prefix (str): prefix.
            bucket_name (str, optional): bucket name. Defaults to None.
            count (int, optional): count to return. Defaults to -1.
            postfix (str, optional): postfix. Defaults to "".
            recursive (bool, optional): recursive. Defaults to True.
            include_folders (bool, optional): include folders. Defaults to False.

        Returns:
            List[str]: list of objects.
        """
        prefix = f"{env.abcli_aws_s3_prefix}/{prefix}"

        if bucket_name is None:
            bucket_name = self.bucket_name

        output = []
        try:
            import boto3

            output = [
                string.after(object_summary.key, prefix)
                for object_summary in boto3.resource("s3")
                .Bucket(bucket_name)
                .objects.filter(Prefix=prefix)
                # .limit(count)
            ]
        except:
            crash_report("-storage: list_of_objects: failed.")

        output = [thing[1:] if thing.startswith("/") else thing for thing in output]

        if include_folders:
            output = sorted(list({thing.split("/")[0] for thing in output}))
        elif not recursive:
            output = [thing for thing in output if "/" not in thing]

        if postfix:
            output = [thing for thing in output if thing.endswith(postfix)]

        if count != -1:
            output = output[:count]

        return output

    def exists(
        self,
        object_name,
        bucket_name=None,
    ):
        """does object_name exist?

        Args:
            object_name (str): object name.
            bucket_name (str, optional): bucket name. Defaults to None.

        Returns:
            bool: success
        """
        if bucket_name is None:
            bucket_name = self.bucket_name

        import boto3
        import botocore

        try:
            boto3.resource("s3").Object(
                bucket_name, "/".join([env.abcli_aws_s3_prefix, object_name])
            ).load()
        except botocore.exceptions.ClientError as e:
            if e.response["Error"]["Code"] != "404":
                crash_report("-storage: exists: failed.")
            return False

        return True

    def upload_file(
        self,
        filename,
        object_name=None,
        bucket_name=None,
        overwrite=False,
    ):
        """upload file.

        Args:
            filename (str): filename.
            object_name (str, optional): object name. Defaults to None.
            bucket_name (str, optional): bucket name. Defaults to None.
            overwrite (bool, optional): overwrite. Defaults to False.

        Returns:
            bool: success.
            str: bucket_name.
            str: object_name.
        """
        if bucket_name is None:
            bucket_name = self.bucket_name

        if not filename:
            logger.warning("-storage: upload_file: no file.")
            return False, bucket_name, ""

        if object_name is None:
            object_name = "{}/{}{}".format(
                env.abcli_aws_s3_prefix,
                env.abcli_object_name,
                (
                    string.after(filename, env.abcli_object_name)
                    if env.abcli_object_name in filename
                    else filename
                ),
            )

        success = True
        if not self.exists(object_name) or overwrite:
            time_ = time.time()
            try:
                self.s3.upload_file(filename, bucket_name, object_name)
            except:
                crash_report("-storage: upload_file: failed.")
                success = False

            if success:
                logger.info(
                    "uploaded {}:{} -> {}/{}: {}.".format(
                        filename,
                        string.pretty_bytes(file.size(filename)),
                        bucket_name,
                        object_name,
                        string.pretty_duration(
                            time.time() - time_,
                            include_ms=True,
                            short=True,
                        ),
                    )
                )

        return success, bucket_name, object_name

    def url(self, object_name, filename):
        """return url for object_name/filename.

        Args:
            object_name (str): object name.
            filename (str): filename.

        Returns:
            bool: success.
        """
        return "https://{}.s3.{}.amazonaws.com/{}/{}/{}".format(
            self.bucket_name,
            self.region,
            env.abcli_aws_s3_prefix,
            object_name,
            filename,
        )
