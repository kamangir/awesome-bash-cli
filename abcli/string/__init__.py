import os
import time

os.environ["TZ"] = "America/New_York"
time.tzset()

NAME = "abcli.string"

from abcli.string.consts import *
from abcli.string.functions import *
