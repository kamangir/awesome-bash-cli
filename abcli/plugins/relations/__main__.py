import argparse
from . import *
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="clone|create|get|list|search|set",
)
parser.add_argument(
    "--count",
    type=int,
    default=-1,
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--filename",
    type=str,
)
parser.add_argument(
    "--item_name",
    default="object",
    type=str,
)
parser.add_argument(
    "--log",
    default=1,
    type=int,
    help="0|1",
)
parser.add_argument(
    "--object_1",
    type=str,
)
parser.add_argument(
    "--object_2",
    type=str,
)
parser.add_argument(
    "--relation",
    default="",
    type=str,
)
parser.add_argument(
    "--return_list",
    type=int,
    default=0,
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = False
if args.task == "clone":
    success = clone(args.object_1, args.object_2)
elif args.task == "create":
    success = create()
elif args.task == "get":
    relation = get(args.object_1, args.object_2)
    if args.log:
        logger.info(
            f"{args.object_1} -{f'{relation}->' if relation else 'X-'} {args.object_2}"
        )
    else:
        print(relation)
    success = True
elif args.task == "list":
    for thing in sorted(
        ["{} : {}".format(this, that) for this, that in inverse_of.items() if this]
    ):
        print(thing)
    success = True
elif args.task == "search":
    output = search(args.object_1, args.relation, args.count)

    if args.relation:
        if args.log:
            logger.info(f"{len(output):,} {args.item_name}(s): {delim.join(output)}")
        else:
            print(delim.join(output))
    else:
        print(output)

    success = file.save_json(args.filename, output) if args.filename else True
elif args.task == "set":
    success = set_(args.object_1, args.object_2, args.relation)
else:
    success = None

sys_exit(logger, NAME, args.task, success, log=args.log)
