import argparse
from abcli import env
from . import *

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="create_bucket|download_file|exists|list_of_objects|upload_file",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--bucket_name",
    type=str,
    default=env.abcli_aws_s3_bucket_name,
)
parser.add_argument(
    "--count",
    type=int,
    default=9999,
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--item_name",
    default="object",
    type=str,
)
parser.add_argument(
    "--log",
    default=1,
    type=int,
    help="0|1",
)
parser.add_argument(
    "--object_name",
    type=str,
    default="",
)
parser.add_argument(
    "--postfix",
    type=str,
    default="",
)
parser.add_argument(
    "--prefix",
    type=str,
    default="",
)
parser.add_argument(
    "--recursive",
    type=int,
    default=1,
    help="0|1",
)

args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = True
output = None
if args.task == "create_bucket":
    success = Storage(args.bucket_name).s3 is not None
elif args.task == "download_file":
    success = Storage(args.bucket_name).download_file(
        bucket_name=args.bucket_name,
        object_name=args.object_name,
        filename=args.filename,
    )
elif args.task == "exists":
    print(Storage(args.bucket_name).exists(args.object_name))
    success = True
elif args.task == "list_of_objects":
    output = Storage(args.bucket_name).list_of_objects(
        count=args.count,
        postfix=args.postfix,
        prefix=args.prefix,
        recursive=args.recursive,
    )
    success = True
elif args.task == "upload_file":
    success = Storage(args.bucket_name).upload_file(
        filename=args.filename,
        object_name=args.object_name,
        bucket_name=args.bucket_name,
    )
else:
    print(f"-{NAME}: {args.task}: command not found.")

if success and output is not None:
    if args.log:
        print(f"{len(output):,} {args.item_name}(s): {delim.join(output)}")
    else:
        print(delim.join(output))

if not success:
    print(f"-{NAME}: {args.task}: failed.")
