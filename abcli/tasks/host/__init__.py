import os
import random
import string
from ... import *
from ...plugins import tags
from ...logging import crash_report
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.tasks.host"

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


host_tags = None


def get_tags(cache=True):
    global host_tags

    if cache and host_tags is not None:
        return host_tags

    host_tags = tags.get(get_name())
    return host_tags


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


def signature():
    import platform

    return (
        [fullname()]
        + get_tags()
        + [get_name()]
        + tensor_processing_signature()
        + [
            "Python {}".format(platform.python_version()),
            "{} {}".format(platform.system(), platform.release()),
        ]
        + (lambda x: [x] if x else [])(os.getenv("abcli_wifi_ssid"))
    )


def tensor_processing_signature():
    try:
        import tensorflow

        tensorflow_version = "TensorFlow {}".format(tensorflow.__version__)
    except:
        pass

    try:
        import tensorflow.keras as keras

        keras_version = "Keras {}".format(keras.__version__)
    except:
        pass
    try:
        import tflite_runtime.interpreter as tflite

        tflite_version = "TensorFlow Lite"
    except:
        pass
    return [
        thing for thing in [tflite_version, tensorflow_version, keras_version] if thing
    ]
