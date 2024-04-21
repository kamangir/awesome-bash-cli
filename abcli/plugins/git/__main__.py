import argparse
from abcli.plugins.git import increment_version, NAME
from abcli.logger import logger


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
    success = increment_version(
        repo_path=args.repo_path,
        verbose=args.verbose == 1,
    )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
