import argparse
from abcli import file
from . import *
from abcli.logger import logger


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="get|add_signature",
)
parser.add_argument(
    "--application",
    type=str,
    default="",
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--header",
    type=str,
    default="",
    help="this|that",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--footer",
    type=str,
    default="",
    help="this|that",
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
    help="0|1",
)
parser.add_argument(
    "--word_wrap",
    default=0,
    type=int,
    help="0|1",
)
parser.add_argument(
    "--name",
    type=str,
    default=".",
)
parser.add_argument(
    "--keyword",
    type=str,
    help="name|tags",
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
        from abcli.plugins import tags

        output = tags.get(args.name if args.name not in ",.".split(",") else get_name())
        success = True
    else:
        logger.error(f"-{NAME}: get: {args.keyword}: unknown keyword.")
        print("unknown")
elif args.task == "add_signature":
    import numpy as np

    success, image = file.load_image(args.filename)
    if success:
        from abcli.plugins.graphics import add_signature
        from abcli.modules.objects import signature as header

        success = file.save_image(
            args.filename,
            add_signature(
                image,
                [args.header] + [" | ".join(header())],
                [args.footer] + [" | ".join([args.application] + signature())],
                word_wrap=args.word_wrap,
            ),
        )

    if success:
        logger.info(
            f"{NAME}.add_signature({args.filename},{args.header},{args.footer})"
        )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if success and output is not None:
    if args.log:
        logger.info(f"{len(output):,} {args.item_name}(s): {delim.join(output)}")
    else:
        print(delim.join(output))

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
