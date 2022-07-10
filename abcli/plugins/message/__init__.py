import copy
import os
import os.path
from ... import *
from ... import string
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.message"


class Message(object):
    def __init__(
        self,
        raw={},
        id=" ",
        data={},
        filename="",
        recipient="",
        reply_id=" ",
        subject="",
    ):
        from ...tasks import host
        from ...plugins.storage import instance as storage

        self.subject = raw.get("subject", subject)

        self.sender = raw.get("sender", host.get_name())
        self.recipient = raw.get("recipient", recipient)

        self.id = raw.get("id", string.random_(16) if id == "random" else id)
        self.reply_id = raw.get("reply_id", reply_id)

        self.data = raw.get("data", data)
        if isinstance(self.data, str):
            try:
                self.data = eval(self.data)
            except:
                self.data = {}
                logger.warning(f"-message: bad data: {raw}")

        if filename:
            self.data["filename"] = filename
            (
                _,
                self.data["bucket_name"],
                self.data["object_name"],
            ) = storage.upload_file(filename)

    def as_string(self):
        """return self as string.

        Returns:
            str: description of self.
        """
        output = "message: {} -{}-> {}{}{}".format(
            self.sender,
            self.subject,
            self.recipient,
            f" #{self.id}" if self.id.strip() else "",
            f" :#{self.reply_id}" if self.reply_id.strip() else "",
        )
        if "object_name" in self.data:
            output += f" : {self.data['object_name']}"
        if "utc_timestamp" in self.data:
            output += " - {}".format(
                string.pretty_duration(
                    string.utc_timestamp() - self.data["utc_timestamp"],
                    largest=True,
                    include_ms=True,
                    short=True,
                ),
            )

        return output

    @property
    def filename(self):
        """get filename.

        Returns:
            str: filename.
        """
        from ...plugins.storage import instance as storage

        if (
            not self.data["filename"]
            and self.data.get("bucket_name", "")
            and self.data.get("object_name", "")
        ):
            filename = os.path.join(
                os.getenv("abcli_object_path"),
                "auxiliary",
                "-".join(
                    [self.data["bucket_name"]] + self.data["object_name"].split("/")
                ),
            )

            if storage.download_file(
                self.data["bucket_name"],
                self.data["object_name"],
                filename,
            ):
                self.data["filename"] = filename

        return self.data["filename"]

    def reply(self):
        """reply to message

        Returns:
            Message: reply.
        """
        return Message(
            recipient=self.sender,
            reply_id=self.id,
            subject=self.subject[-1::-1],
        )

    def submit(self):
        """submit self.

        Returns:
            bool: success.
        """
        from .agent import instance as messenger

        self.data["utc_timestamp"] = string.utc_timestamp()

        return messenger.queue(self.recipient).submit(self)
