import argparse
from abcli.plugins.git import version, NAME
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="increment_version",
)
parser.add_argument(
    "--repo_path",
    type=str,
)
parser.add_argument(
    "--verbose",
    type=int,
    default="0",
    help="0|1",
)
args = parser.parse_args()

success = False
if args.task == "increment_version":
    success = version.increment(
        repo_path=args.repo_path,
        verbose=args.verbose == 1,
    )
else:
    success = None

sys_exit(logger, NAME, args.task, success)
