import argparse
from abcli import name, version

parser = argparse.ArgumentParser(name, description=f"{NAME}-{version}")
parser.add_argument("task", type=str, help="TBD")
args = parser.parse_args()

success = False
if args.task == "TBD":
    success = True
else:
    print(f"-{NAME}: {args.task}: command not found.")

if not success:
    print(f"-{NAME}: {args.task}: failed.")
