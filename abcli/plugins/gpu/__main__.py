import argparse
from . import *
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    help="status|validate",
)
args = parser.parse_args()

success = False
if args.task == "status":
    success = True
    print(str(get_status()).lower())
elif args.task == "validate":
    success = validate()
else:
    success = None

sys_exit(logger, NAME, args.task, success)
