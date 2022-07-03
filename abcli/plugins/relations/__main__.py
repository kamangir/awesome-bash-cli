import argparse
from . import *
from ... import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="get,list,search,set",
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
    "--log",
    default=1,
    type=int,
    help="0/1",
)
parser.add_argument(
    "--relation",
    type=str,
)
parser.add_argument(
    "--return_list",
    type=int,
    default=0,
)
args = parser.parse_args()

success = False
if args.task == "get":
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
    success = True
    output = {}
    for object in args.object_1.split(","):
        output_ = search(object, {"relation": args.relation})
        for key in output_:
            output[key] = output.get(key, []) + output_[key]

    if args.return_list:
        output = reduce(lambda x, y: x + y, output.values(), [])
        if args.count != -1:
            output = list(reversed(output))[: args.count]

    if args.filename:
        success = file.save_json(args.filename, output)

    if args.return_list:
        output = (" " if args.delim == "space" else args.delim).join(output)

    print(output)
elif args.task == "set":
    success = set_(args.object_1, args.object_2, args.relation)
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
