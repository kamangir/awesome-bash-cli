import argparse
import numpy as np

from . import *

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    help="replace",
)
parser.add_argument(
    "--filename",
    type=str,
)
parser.add_argument(
    "--that",
    type=str,
)
parser.add_argument(
    "--this",
    type=str,
)
args = parser.parse_args()

success = False
if args.task == "replace":
    success, content = load_text(args.filename)
    if success:
        success = save_text(
            args.filename,
            [line.replace(args.this, args.that) for line in content],
        )
else:
    logger.error('{}: unknown task "{}".'.format(name, args.task))

if not success:
    logger.error("{}.{} failed.".format(name, args.task))
