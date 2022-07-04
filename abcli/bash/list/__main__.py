import argparse

from ... import *

name = f"{shortname}.bash.list"

list_of_tasks = "in,intersect,len,nonempty,resize,sort"

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    help=list_of_tasks,
)
parser.add_argument(
    "--count",
    type=int,
)
parser.add_argument(
    "--delim",
    type=str,
    default=",",
)
parser.add_argument(
    "--item",
    type=str,
)
parser.add_argument(
    "--items",
    type=str,
)
parser.add_argument(
    "--items_1",
    type=str,
)
parser.add_argument(
    "--items_2",
    type=str,
)
parser.add_argument(
    "--unique",
    type=int,
    help="0/1",
    default=0,
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

list_of_items = (
    [item for item in args.items.split(delim) if item]
    if isinstance(args.items, str)
    else None
)

success = args.task in list_of_tasks.split(",")
if args.task == "in":
    print("True" if args.item in list_of_items else "False")
elif args.task == "intersect":
    print(
        delim.join(
            [
                item
                for item in [item for item in args.items_1.split(delim)]
                if item in [item for item in args.items_2.split(delim)] and item
            ]
        )
    )
elif args.task == "len":
    print(len(list_of_items))
elif args.task == "nonempty":
    print(delim.join(list_of_items))
elif args.task == "resize":
    print(delim.join(list_of_items[: args.count]))
elif args.task == "sort":
    if args.unique:
        list_of_items = list(set(list_of_items))

    print(delim.join(sorted(list_of_items)))
else:
    print(f"-{name}: {args.task}: command not found")

if not success:
    print(f"-{name}: {args.task}: failed")
