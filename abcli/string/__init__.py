import os
import time

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# Toronto: "America/New_York"
os.environ["TZ"] = "America/Los_Angeles"
time.tzset()

NAME = "abcli.string"

from .constants import *
from .functions import *
