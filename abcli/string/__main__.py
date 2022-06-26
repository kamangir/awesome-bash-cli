import argparse
from . import *


parser = argparse.ArgumentParser()
parser.add_argument(
    "task",
    type=str,
    default="",
    help="argparse",
)
parser.add_argument(
    "--list_of_args",
    type=str,
)
parser.add_argument(
    "--arg",
    type=str,
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
args = parser.parse_args()

success = False
if args.task == "argparse":
    items = args.list_of_args.replace("  ", " ").split(" ")
    print(
        {name: value for name, value in zip(items[:-1:2], items[1::2])}.get(
            args.arg, args.default
        )
    )
    success = True
else:
    print('string: unknown task "{}".'.format(args.task))

if not success:
    print("string({}): failed.".format(args.task))
