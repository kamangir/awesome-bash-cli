import abcli.file as file
from abcli.modules import objects
from .classes import Message
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def submit_object(
    object_name,
    recipient="stream",
    extensions="png,jpg,jpeg",
):
    logger.info(f"message.submit_object: {object_name} -> {recipient}")

    success = True
    for filename in objects.list_of_files(object_name):
        if file.extension(filename) in extensions.split(","):
            if not Message(
                filename=filename,
                recipient=recipient,
                subject="frame",
            ).submit():
                success = False

    return success
