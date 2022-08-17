from functools import reduce
from ... import shortname
from ... import host
from ... import logging
import logging

logger = logging.getLogger(__name__)


name = f"{shortname}.modules.hardware"

from .classes import *

instance = RPi() if host.is_rpi() else Jetson() if host.is_jetson() else Hardware()
