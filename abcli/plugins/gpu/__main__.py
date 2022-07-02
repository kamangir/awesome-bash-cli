import argparse
from ... import *
from . import *
from ... import logging
import logging

logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser(name)
parser.add_argument("task", type=str, help="validate")
args = parser.parse_args()

success = False
if args.task == "validate":
    success = validate()
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
