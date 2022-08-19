NAME = "abcli.modules.hardware"

from abcli.modules import host
from abcli.modules.hardware.classes import Jetson, Hardware, RPi


instance = RPi() if host.is_rpi() else Jetson() if host.is_jetson() else Hardware()
