import argparse
from functools import reduce
import time
from . import *
from abcli import file
from abcli import VERSION
from abcli.logger import logger


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="update",
    help="listen_as|submit|submit_object|update",
)
parser.add_argument(
    "--count",
    type=int,
    default=100,
)
parser.add_argument(
    "--data",
    type=str,
    default="{}",
)
parser.add_argument(
    "--delete",
    default=0,
    type=int,
)
parser.add_argument(
    "--subject",
    type=str,
    default="void",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--object_name",
    type=str,
    default="",
)
parser.add_argument(
    "--recipient",
    type=str,
    default="public",
)
parser.add_argument(
    "--sender",
    type=str,
    default="",
)
parser.add_argument(
    "--sleep",
    type=int,
    default=1,
    help="in ms",
)
args = parser.parse_args()

success = False
if args.task == "listen_as":
    from .messenger import instance as messenger

    messages = []

    try:
        while len(messages) < args.count:
            messages += [
                message
                for message in messenger.request(
                    args.recipient,
                    delete=args.delete,
                )[1]
                if message.sender in args.sender.split(",") or not args.sender
            ]
            time.sleep(args.sleep)
    except KeyboardInterrupt:
        logger.info(f"{NAME}: Ctrl+C: stopped.")

    success = file.save_json(args.filename, messages) if args.filename else True
elif args.task == "submit":
    success = reduce(
        lambda a, b: a and b,
        [
            Message(
                data=args.data,
                filename=args.filename,
                recipient=recipient,
                subject=args.subject,
            ).submit()
            for recipient in args.recipient.split(",")
        ],
        True,
    )
elif args.task == "submit_object":
    success = submit_object(
        args.object_name,
        args.recipient,
    )
elif args.task == "update":
    success = reduce(
        lambda a, b: a and b,
        [
            Message(
                recipient=recipient,
                subject="update",
                data={"version": VERSION},
            ).submit()
            for recipient in args.recipient.split(",")
        ],
        True,
    )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
