import argparse
from . import *
from abcli import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name, description=f"{name}-{version}")
parser.add_argument(
    "task",
    type=str,
    help="TBD",
)
args = parser.parse_args()

success = False
if args.task == "TBD":
    success = True
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
