import argparse
from abcli.bash.colors import CYAN, NC
from abcli.logger import logger

NAME = "abcli.bash.logging"


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="hr",
)
parser.add_argument(
    "--width",
    type=int,
    default=80,
)
parser.add_argument(
    "--pattern",
    type=str,
    default=". .. ... .. ",
)
args = parser.parse_args()


success = False
if args.task == "hr":
    success = True
    print(
        "{}{}{}".format(
            CYAN,
            ((args.width // len(args.pattern) + 1) * args.pattern)[: args.width],
            NC,
        )
    )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
