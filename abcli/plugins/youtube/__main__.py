import argparse
from . import *
from abcli import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="cat|download|duration|search|is_CC|validate",
)
parser.add_argument(
    "--keyword",
    type=str,
    default="",
    help="",
)
parser.add_argument(
    "--part",
    type=str,
    default="contentDetails",
    help="contentDetails|status",
)
parser.add_argument(
    "--video_id",
    type=str,
    default="",
    help="",
)
parser.add_argument(
    "--what",
    type=str,
    default="keyword",
    help="channelId|keyword",
)
args = parser.parse_args()

success = False
if args.task == "cat":
    print(info(args.video_id, args.part))
    success = True
elif args.task == "download":
    success = download(args.video_id)
elif args.task == "duration":
    success = True
    print(duration(args.video_id))
elif args.task == "is_CC":
    success = True
    print(",".join([str(is_CC(video_id)) for video_id in args.video_id.split(",")]))
elif args.task == "search":
    success, list_of_video_id = search(args.keyword, args.what)
    if success:
        print(",".join(list_of_video_id))
elif args.task == "validate":
    success = validate()
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")


if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
