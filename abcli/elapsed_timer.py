import time
from abcli import string


class ElapsedTimer:
    def __init__(self):
        self.start_time = time.time()
        self.elapsed_time = None

    def stop(self):
        if self.start_time is None:
            return

        self.elapsed_time = time.time() - self.start_time
        self.start_time = None

    def elapsed_pretty(self, **kwargs):
        self.stop()
        return (
            "None"
            if self.elapsed_time is None
            else string.pretty_duration(self.elapsed_time, **kwargs)
        )
