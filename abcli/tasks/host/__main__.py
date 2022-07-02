import argparse
from . import *
from ...plugins import tags
from ... import file
from ... import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="get,sign",
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--item_name",
    default="tag",
    type=str,
)
parser.add_argument(
    "--log",
    default=1,
    type=int,
    help="0/1",
)
parser.add_argument(
    "--name",
    type=str,
    default=".",
)
parser.add_argument(
    "--keyword",
    type=str,
    help="name,tags",
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = False
output = None
if args.task == "get":
    if args.keyword == "name":
        print(get_name())
        success = True
    elif args.keyword == "tags":
        output = tags.get(args.name if args.name not in ",.".split(",") else get_name())
        success = True
    else:
        logger.error(f"-{name}: get: {args.keyword}: unknown keyword.")
        print("unknown")
elif args.task == "sign":
    success, image = file.load_image(args.filename)
    if success:
        from abcli.graphics import add_signature
        from abcli.tasks.objects import signature as header

        success = file.save_image(
            args.filename,
            add_signature(
                image,
                [" | ".join(header())],
                [" | ".join(signature())],
            ),
        )

    if success:
        logger.info("host.sign({})".format(args.filename))
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if success and output is not None:
    if args.log:
        logger.info(f"{len(output):,} {args.item_name}(s): {delim.join(output)}")
    else:
        print(delim.join(output))

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
