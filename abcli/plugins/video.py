import argparse
import cv2
from abcli import file
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


NAME = "abcli.plugins.video"

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="resize|size_of",
)
parser.add_argument(
    "--filename",
    type=str,
)
parser.add_argument(
    "--scale",
    type=float,
)
parser.add_argument(
    "--size",
    type=str,
    help="widthxheight",
)
args = parser.parse_args()

success = False
if args.task == "resize":
    (width, height) = (int(thing) for thing in args.size.split("x"))

    success, image = file.load_image(args.filename)

    if success:
        success = file.save_image(
            args.filename,
            cv2.resize(
                image,
                (width, height),
            ),
        )

    if success:
        logger.info(f"{NAME}.resize({width},{height}): {args.filename}")
elif args.task == "size_of":
    success, image = file.load_image(args.filename)

    if success:
        print(
            "{}x{}".format(
                2 * int(image.shape[1] / 2 / args.scale),
                2 * int(image.shape[0] / 2 / args.scale),
            )
        )
else:
    success = None

sys_exit(logger, NAME, args.task, success)
