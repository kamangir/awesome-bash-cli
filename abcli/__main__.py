import argparse
from . import *


parser = argparse.ArgumentParser(name, description=f"{name}-{version}")
parser.add_argument("task", type=str, help="TBD")
args = parser.parse_args()

success = False
if args.task == "TBD":
    success = True
else:
    print(f"-{name}: {args.task}: command not found.")

if not success:
    print(f"-{name}: {args.task}: failed.")
