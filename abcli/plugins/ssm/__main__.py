import argparse
from blueness import module
from abcli import VERSION, NAME
from abcli.plugins.ssm.functions import get_secret, put_secret, rm_secret
from abcli.logger import logger
from blueness.argparse.generic import sys_exit

NAME = module.name(__file__, NAME)

parser = argparse.ArgumentParser(NAME, description=f"{NAME}-{VERSION}")
parser.add_argument(
    "task",
    type=str,
    default="",
    help="get|put|rm",
)
parser.add_argument(
    "--description",
    type=str,
    default="",
)
parser.add_argument(
    "--name",
    type=str,
)
parser.add_argument(
    "--value",
    type=str,
)
args = parser.parse_args()

success = False
if args.task == "get":
    success, value = get_secret(args.name)

    if success:
        print(value)
elif args.task == "put":
    success, _ = put_secret(
        args.name,
        args.value,
        args.description,
    )
elif args.task == "rm":
    success, _ = rm_secret(args.name)
else:
    success = None

sys_exit(logger, NAME, args.task, success, log=False)
