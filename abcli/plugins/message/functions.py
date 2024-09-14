from blue_objects import file, objects

from abcli.plugins.message.classes import Message
from abcli.logger import logger


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
