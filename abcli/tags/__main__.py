import argparse
from . import *
from .types import *
from .utils import *
from .. import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="for_type,get,list_of_types,search,set",
)
parser.add_argument(
    "--after",
    type=str,
    default="",
    help="123-4-e",
)
parser.add_argument(
    "--object",
    type=str,
    default=None,
)
parser.add_argument(
    "--before",
    type=str,
    default="",
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
    "--host",
    default=-1,
    type=int,
    help="0/1/-1",
)
parser.add_argument(
    "--item_name",
    default="object",
    type=str,
)
parser.add_argument(
    "--shuffle",
    default=0,
    type=int,
    help="0/1",
)
parser.add_argument(
    "--tag",
    type=str,
    default="",
)
parser.add_argument(
    "--tags",
    type=str,
    default="",
    help="this,~that",
)
parser.add_argument(
    "--type",
    type=str,
    default="",
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = False
if args.task == "for_type":
    print(delim.join(host_type.get(args.type, [])))
    success = True
elif args.task == "get":
    print(delim.join(get(args.object)))
    success = True
elif args.task == "list_of_types":
    print(delim.join(list(host_type.keys())))
    success = True
elif args.task == "search":
    keywords = search(
        args.tags,
        {
            "after": args.after,
            "before": args.before,
            "count": args.count,
            "host": args.host,
            "shuffle": args.shuffle,
        },
    )

    if args.log:
        logger.info(f"{len(keywords):,} {args.item_name}(s): {delim.join(keywords)}")
    else:
        print(delim.join(keywords))

    success = True
elif args.task == "set":
    success = set_(args.object, args.tags)
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
