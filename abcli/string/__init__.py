import os
import time

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
os.environ["TZ"] = "America/Vancouver"
time.tzset()

from .constants import *
from .functions import *
