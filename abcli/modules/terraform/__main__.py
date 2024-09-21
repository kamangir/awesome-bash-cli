import argparse

from blueness import module
from blueness.argparse.generic import sys_exit

from abcli import NAME
from abcli.modules.terraform.functions import (
    lxde,
    mac,
    poster,
    rpi,
    ubuntu,
)
from abcli.logger import logger

NAME = module.name(__file__, NAME)


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="terraform",
    help="poster,terraform",
)
parser.add_argument(
    "--filename",
    type=str,
    default="background.jpg",
)
parser.add_argument(
    "--is_headless",
    type=str,
    default="false",
    help="true/false",
)
parser.add_argument(
    "--target",
    type=str,
    default="none",
    help="lxde/mac/rpi/ubuntu",
)
parser.add_argument(
    "--user",
    type=str,
    default="user",
)
args, _ = parser.parse_known_args()

success = False
if args.task == "poster":
    success = poster(args.filename)
elif args.task == "terraform":
    logger.info("terraforming {}".format(args.target))

    if args.target == "lxde":
        success = lxde(args.user)
    elif args.target == "mac":
        success = mac(args.user)
    elif args.target == "rpi":
        success = rpi(
            args.user,
            is_headless=args.is_headless == "true",
        )
    elif args.target == "ubuntu":
        success = ubuntu(args.user)
    else:
        logger.error(f"-{NAME}: {args.target}: target not found.")
else:
    success = None

sys_exit(logger, NAME, args.task, success)
