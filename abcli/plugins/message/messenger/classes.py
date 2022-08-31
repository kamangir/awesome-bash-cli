from abcli.plugins.message.queue import MessageQueue


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

    def request(self, recipients=None, count=10, delete=False):
        """request messages.

        Args:
            recipients (Any, optional): recipients. Defaults to None.
            count (int, optional): count to return. Defaults to 10.
            delete (bool, optional): delete messages. Defaults to False.

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
            success_, messages = self.queue(recipient).request(
                count=count,
                delete=delete,
            )

            if not success_:
                success = False
                break
            elif messages:
                output.extend(messages)

        return success, output
