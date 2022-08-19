import argparse
from functools import reduce
from . import *
import time
from ... import file
from ... import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="update",
    help="listen_to,submit,update",
)
parser.add_argument(
    "--count",
    type=int,
    default=10,
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
if args.task == "listen_to":
    from abcli.plugins.message.messenger import instance as messenger

    messages = []

    while len(messages) < args.count:
        messages += [
            message
            for message in messenger.request(
                args.recipient,
                count=args.count,
                delete=args.delete,
            )[1]
            if message.sender in args.sender.split(",") or not args.sender
        ]
        time.sleep(args.sleep)

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
elif args.task == "update":
    success = reduce(
        lambda a, b: a and b,
        [
            Message(
                recipient=recipient,
                subject="update",
                data={"version": version},
            ).submit()
            for recipient in args.recipient.split(",")
        ],
        True,
    )
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
