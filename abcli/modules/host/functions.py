import os
from abcli import fullname
from abcli import file
from abcli import string
from abcli.plugins import tags
from . import HOST_NAME, HOST_TAGS, NAME
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def get_name(cache=True):
    global HOST_NAME

    if cache and HOST_NAME is not None:
        return HOST_NAME

    HOST_NAME = get_name_()
    return HOST_NAME


def get_name_():
    default = string.random_(5)

    if is_ec2():
        return os.getenv("abcli_ec2_instance_id", default)

    if is_jetson():
        return os.getenv("abcli_jetson_nano_serial_number", default)

    if is_ubuntu():
        return os.getenv("abcli_ubuntu_computer_id", default)

    if is_mac():
        return os.getenv("USER", default)

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
        crash_report(f"-{NAME}: get_name(): failed.")

    return default


def get_seed_filename():
    return (
        "/media/abcli/SEED/abcli/jetson.sh"
        if is_jetson()
        else "/Volumes/seed/abcli/ubuntu.sh"
        if is_ubuntu()
        else "/media/pi/SEED/abcli/rpi.sh"
        if is_rpi()
        else ""
    )


def get_tags(cache=True):
    global HOST_TAGS

    if cache and HOST_TAGS is not None:
        return HOST_TAGS

    HOST_TAGS = tags.get(get_name(cache=cache))
    return HOST_TAGS


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


def shell(
    command,
    clean_after=False,
    return_output=False,
    work_dir=".",
):
    """execute command in shell.

    Args:
        command (str): command
        keep_blank (bool, optional): keep blank lines in output. Defaults to True.
        clean_after (bool, optional): delete output file. Defaults to False.
        return_output (bool, optional): return output. Defaults to False.
        work_dir (str, optional): working directory. Defaults to ".".
        strip (bool, optional): strip output. Defaults to False.

    Returns:
        bool: success.
        (List[str], optional): output.
    """
    logger.debug(f"host.shell({command})")

    success = True
    output = []

    if return_output:
        output_filename = file.auxiliary("shell", "txt")
        command += f" > {output_filename}"

    current_path = os.getcwd()
    try:
        os.chdir(work_dir)

        try:
            os.system(command)
        except:
            crash_report(f"host.shell({command}) failed")
            success = False

    finally:
        os.chdir(current_path)

    if success and return_output:
        success, output = file.load_text(output_filename)

        if clean_after:
            file.delete(output_filename)

    return (success, output) if return_output else success


def signature():
    import platform

    return (
        [fullname()]
        + [get_name()]
        + tensor_processing_signature()
        + [
            "Python {}".format(platform.python_version()),
            "{} {}".format(platform.system(), platform.release()),
        ]
        + (lambda x: [x] if x else [])(os.getenv("abcli_wifi_ssid", ""))
    )


def tensor_processing_signature():
    output = []

    try:
        import tensorflow

        output += [f"TensorFlow {tensorflow.__version__}"]
    except:
        pass

    try:
        import tensorflow.keras as keras

        output += [f"Keras {keras.__version__}"]
    except:
        pass

    try:
        import tflite_runtime.interpreter as tflite

        output += [f"TensorFlow Lite"]
    except:
        pass

    return output
