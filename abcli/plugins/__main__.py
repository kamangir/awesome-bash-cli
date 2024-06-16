import argparse
from abcli import VERSION
from abcli.plugins import NAME
from abcli.plugins.functions import get_module_name, get_plugin_name, list_of_external
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="get_module_name|get_plugin_name|list_of_external",
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--log",
    default=1,
    type=int,
    help="0|1",
)
parser.add_argument(
    "--repo_names",
    default=0,
    type=int,
    help="0|1",
)
parser.add_argument(
    "--repo_name",
    default="",
    type=str,
)
parser.add_argument(
    "--plugin_name",
    default="",
    type=str,
)
parser.add_argument(
    "--from_plugin_name",
    default=0,
    type=int,
    help="0|1",
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = False
if args.task == "get_module_name":
    success = True
    print(get_module_name(args.repo_name))
elif args.task == "get_plugin_name":
    success = True
    print(get_plugin_name(args.repo_name))
elif args.task == "list_of_external":
    output = list_of_external(args.repo_names == 1)
    if args.log:
        logger.info(
            "{:,} external {}(s): {}".format(
                len(output),
                "repo" if args.repo_names else "plugin",
                delim.join(output),
            )
        )
    else:
        print(delim.join(output))
    success = True
else:
    success = None

sys_exit(logger, NAME, args.task, success, log=args.log)
