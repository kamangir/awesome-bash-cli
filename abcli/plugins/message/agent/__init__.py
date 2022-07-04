from .... import *
from ....tasks import host
from ..queue import *
from .... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.message.agent"


class Messenger(object):
    def __init__(self, recipients=[]):
        self.recipients = recipients
        self._queue = {}

    def queue(self, name):
        """get message queue[name].

        Args:
            name (str): name

        Returns:
            MessageQueue: message queue.
        """
        if name not in self._queue:
            self._queue[name] = MessageQueue(name)

        return self._queue[name]

    def request(self, recipients=None):
        """request messages.

        Args:
            recipients (Any, optional): recipients. Defaults to None.

        Returns:
            bool: success.
            List[Message]: list of messages.
        """
        output = []
        success = True

        if recipients is None:
            recipients = self.recipients

        if isinstance(recipients, str):
            recipients = recipients.split(",")

        for recipient in recipients:
            success_, messages = self.queue(recipient).request()

            if not success_:
                success = False
                break
            elif messages:
                output.extend(messages)

        return success, output


instance = Messenger(
    recipients=list(
        set(
            [
                "public",
                host.get_name(),
            ]
            + host.get_tags()
            + [
                thing
                for thing in host.arguments.get("messenger.recipients", "").split(",")
                if thing
            ]
        )
    )
)
