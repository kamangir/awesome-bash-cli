import os
import random
import string
from .. import *
from ..logging import crash_report
from .. import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.host"

arguments = {}


def get_name():
    random_output = "".join(
        random.choice(string.ascii_lowercase + string.digits) for _ in range(5)
    )

    if is_ec2():
        return os.getenv("abcli_ec2_instance_id", random_output)

    if is_jetson():
        return os.getenv("abcli_jetson_nano_serial_number", random_output)

    if is_ubuntu():
        return os.getenv("abcli_ubuntu_computer_id", random_output)

    if is_mac():
        return os.getenv("USER", "")

    try:
        if is_rpi():
            # https://www.raspberrypi-spy.co.uk/2012/09/getting-your-raspberry-pi-serial-number-using-python/
            with open("/proc/cpuinfo", "r") as fp:
                for line in fp:
                    if line.startswith("Serial"):
                        return line[10:26]

        with open("/sys/firmware/devicetree/base/serial-number", "r") as fp:
            for line in fp:
                return line.strip().replace(chr(0), "")

    except:
        crash_report(f"-{name}: get_name(): failed.")

    return random_output


def is_ec2():
    return os.getenv("abcli_is_ec2", "false") == "true"


def is_jetson():
    return os.getenv("abcli_is_jetson", "false") == "true"


def is_mac():
    return os.getenv("abcli_is_mac", "false") == "true"


def is_rpi():
    return os.getenv("abcli_is_rpi", "false") == "true"


def is_ubuntu():
    return os.getenv("abcli_is_ubuntu", "false") == "true"
