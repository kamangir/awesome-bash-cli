from abcli import string
from . import NAME
from .classes import Message
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


class MessageQueue(object):
    def __init__(self, name):
        self.name = name
        self.queue = None
        self.connect()

        self.utc_timestamp_log = []

    def connect(self):
        try:
            import boto3

            sqs = boto3.resource("sqs")
        except:
            crash_report(f"-{NAME}: connect: {self.name}: failed.")
            return False

        self.queue = None

        try:
            self.queue = sqs.get_queue_by_name(QueueName=self.name)
        except:
            pass

        if self.queue is None:
            try:
                self.queue = sqs.create_queue(
                    QueueName=self.name,
                    Attributes={
                        "MessageRetentionPeriod": "60",
                        "VisibilityTimeout": "0",
                    },
                )
            except:
                crash_report(
                    f"-{NAME}: connect: sqs.create_queue: {self.name}: failed."
                )

        if self.queue is None:
            logger.error(f"-{NAME}: connect: {self.name}: failed.")
            return False

        return True

    def request(self, count=10, delete=False):
        """request messages

        Args:
            count (int, optional): count to return. Defaults to 10.
            delete (bool, optional): delete messages. Defaults to False.

        Returns:
            bool: success
            List[Message]: list of messages.
        """
        import abcli.plugins.message
        import abcli.modules.host as host

        messages = []
        success = False

        if self.queue is None:
            logger.error(f"-{NAME}: request: no queue.")
            return success, messages

        attributes = [
            "data",
            "id",
            "recipient",
            "reply_id",
            "sender",
            "subject",
        ]

        try:
            for msg in self.queue.receive_messages(
                MessageAttributeNames=attributes,
                MaxNumberOfMessages=count,
            ):
                if msg.message_attributes is None:
                    logger.warning("no message_attributes, ignoring.")
                    continue

                message = Message(
                    {
                        attribute: msg.message_attributes.get(attribute).get(
                            "StringValue"
                        )
                        for attribute in attributes
                        if msg.message_attributes.get(attribute) is not None
                    }
                )

                include_message = True
                if "utc_timestamp" in message.data:
                    if message.data["utc_timestamp"] in self.utc_timestamp_log:
                        include_message = False
                    else:
                        self.utc_timestamp_log += [message.data["utc_timestamp"]]

                if message.recipient in [host.name] or delete:
                    msg.delete()

                if include_message:
                    logger.info(message.as_string())
                    messages.append(message)

            success = True
        except:
            crash_report(f"-{NAME}: request: failed.")

        return success, messages

    def submit(self, message):
        """submit message.

        Args:
            message (Message): message.

        Returns:
            bool: success.
        """
        if self.queue is None:
            logger.error(f"-{NAME}: submit: no queue.")
            return False

        try:
            self.queue.send_message(
                MessageBody=message.subject,
                MessageAttributes={
                    "data": {
                        "StringValue": string.as_json(message.data),
                        "DataType": "String",
                    },
                    "id": {
                        "StringValue": message.id,
                        "DataType": "String",
                    },
                    "recipient": {
                        "StringValue": message.recipient,
                        "DataType": "String",
                    },
                    "reply_id": {
                        "StringValue": message.reply_id,
                        "DataType": "String",
                    },
                    "sender": {
                        "StringValue": message.sender,
                        "DataType": "String",
                    },
                    "subject": {
                        "StringValue": message.subject,
                        "DataType": "String",
                    },
                },
            )
        except:
            crash_report(f"-{NAME}: submit: failed.")
            return False

        logger.info(message.as_string())

        return True
