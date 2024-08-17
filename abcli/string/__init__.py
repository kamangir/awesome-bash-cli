import os
import time

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
os.environ["TZ"] = "America/Vancouver"
time.tzset()

from .constants import unit_of
from .functions import (
    after,
    as_json,
    before,
    between,
    pretty_bytes,
    pretty_date,
    pretty_duration,
    pretty_frequency,
    pretty_param,
    pretty_shape,
    pretty_shape_of_matrix,
    random_,
    shorten,
    timestamp,
    utc_timestamp,
)
