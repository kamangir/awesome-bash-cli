import argparse
from abcli import file
from abcli.logger import logger


NAME = "abcli.plugins.git"

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
args = parser.parse_args()

success = False
if args.task == "increment_version":
    logger.info(f"{NAME}.increment_version({args.repo_path})")
    logger.info("🪄")
    success = True
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
