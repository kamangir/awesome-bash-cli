import time
from abcli import string


class Timer:
    def __init__(self, period, name):
        self.count = 0
        self.hot = False
        self.last_hot = None
        self.period = period
        self.name = name
        self.start_time = time.time()

    def reset(self):
        self.hot = False
        self.last_hot = time.time()

    def signature(self):
        current_time = time.time()
        since = None if self.last_hot is None else current_time - self.last_hot

        return "{}:{}/{}~{}".format(
            self.name,
            (
                "?"
                if since is None
                else (
                    string.pretty_duration(
                        since,
                        largest=True,
                        short=True,
                    )
                    if since < self.period / 2
                    else string.pretty_duration(
                        -(self.period - since),
                        largest=True,
                        short=True,
                    )
                )
            ),
            string.pretty_duration(
                self.period,
                largest=True,
                short=True,
            ),
            (
                string.pretty_duration(
                    (current_time - self.start_time) / self.count,
                    largest=True,
                    short=True,
                )
                if self.count
                else "?"
            ),
        )

    def tick(self, wait=False):
        """is this time?

        Args:
            wait (bool, optional): Wait for period before firing. Defaults to False.

        Returns:
            bool: if this is time.
        """
        self.hot = False
        current_time = time.time()

        if self.period != -1:
            if self.last_hot is None:
                if wait:
                    self.last_hot = current_time - 1
                else:
                    self.hot = True
            elif current_time - self.last_hot >= self.period:
                self.hot = True

        if self.hot:
            self.last_hot = current_time
            self.count += 1

        return self.hot
