import argparse

from blueness import module
from blueness.argparse.generic import sys_exit

from abcli import NAME
from abcli.plugins.gpu import get_status, validate
from abcli.logger import logger

NAME = module.name(__file__, NAME)

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
