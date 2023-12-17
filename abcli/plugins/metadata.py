import argparse
from abcli import file
from abcli import logging
import logging

logger = logging.getLogger(__name__)

NAME = "abcli.plugins.metadata"

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="get",
)
parser.add_argument(
    "--filename",
    type=str,
)
parser.add_argument(
    "--key",
    type=str,
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
parser.add_argument(
    "--delim",
    type=str,
    default="",
)
parser.add_argument(
    "--dict_keys",
    type=int,
    default=0,
    help="0|1",
)
parser.add_argument(
    "--dict_values",
    type=int,
    default=0,
    help="0|1",
)

args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = False
if args.task == "get":
    success, metadata = file.load_yaml(args.filename)
    if success:
        try:
            output = metadata
            for key_ in [key_ for key_ in args.key.split(".") if key_]:
                output = output.get(key_, args.default)

            if args.dict_keys:
                output = list(output.keys())
            elif args.dict_values:
                output = list(output.values())

            if delim:
                output = delim.join(output)

            print(output)
        except Exception as e:
            print(type(e).__name__)
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
