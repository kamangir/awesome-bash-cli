from abcli import env
from abcli.modules.objects import object_path
from abcli.modules.host import shell


def download_object(object_name: str) -> bool:
    return shell(
        "aws s3 sync {}/{}/ {}".format(
            env.abcli_s3_object_prefix,
            object_name,
            object_path(object_name, create=True),
        )
    )
