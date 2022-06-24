import argparse

from ... import *

name = f"{shortname}.bash.list"


parser = argparse.ArgumentParser(name, description=f"{name}-{version}")
parser.add_argument("task", type=str, help="in,len,nonempty,resize,sort")
parser.add_argument("--count", type=int)
parser.add_argument("--delim", type=str, default=",")
parser.add_argument("--item", type=str)
parser.add_argument("--items", type=str)
args = parser.parse_args()

delim = " " if args.delim == "space" else "," if not args.delim else args.delim

list_of_items = [thing for thing in args.items.split(delim) if thing]

success = False
if args.task == "in":
    print("True" if args.item in list_of_items else "False")
elif args.task == "len":
    print(len(list_of_items))
elif args.task == "nonempty":
    print(delim.join(list_of_items))
elif args.task == "resize":
    print(delim.join(list_of_items[: args.count]))
elif args.task == "sort":
    print(delim.join(sorted(list_of_items)))
else:
    print(f"-{name}: {args.task}: command not found")

if not success:
    print(f"-{name}: {args.task}: failed")
