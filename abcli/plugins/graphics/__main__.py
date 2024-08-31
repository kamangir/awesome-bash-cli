import argparse
import glob
from abcli.modules import objects
from abcli.plugins.graphics import NAME
from abcli.plugins.graphics.gif import generate_animated_gif
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="generate_animated_gif",
)
parser.add_argument(
    "--object_name",
    type=str,
)
parser.add_argument(
    "--suffix",
    default=".png",
    type=str,
)
parser.add_argument(
    "--output_filename",
    default="",
    type=str,
    help="blank: <object-name>.gif",
)
parser.add_argument(
    "--frame_duration",
    default=150,
    type=int,
    help="ms",
)

args = parser.parse_args()

success = False
if args.task == "generate_animated_gif":
    success = generate_animated_gif(
        list_of_images=sorted(
            list(
                glob.glob(
                    objects.path_of(
                        f"*{args.suffix}",
                        args.object_name,
                    )
                )
            )
        ),
        output_filename=objects.path_of(
            args.output_filename
            if args.output_filename
            else "{}.gif".format(args.object_name)
        ),
        frame_duration=args.frame_duration,
    )
else:
    success = None

sys_exit(logger, NAME, args.task, success)
