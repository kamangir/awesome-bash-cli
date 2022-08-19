import os
from . import host_name_, host_tags_, name
from ... import fullname
from ... import file
from ... import string
from ...plugins import tags
from ...logging import crash_report
from ... import logging
import logging

logger = logging.getLogger(__name__)


def get_name(cache=True):
    global host_name_

    if cache and host_name_ is not None:
        return host_name_

    host_name_ = get_name_()
    return host_name_


def get_name_():
    if is_ec2():
        return os.getenv("abcli_ec2_instance_id")

    if is_jetson():
        return os.getenv("abcli_jetson_nano_serial_number")

    if is_ubuntu():
        return os.getenv("abcli_ubuntu_computer_id")

    if is_mac():
        return os.getenv("USER")

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

    return string.random_(5)


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
    global host_tags_

    if cache and host_tags_ is not None:
        return host_tags_

    host_tags_ = tags.get(get_name(cache=cache))
    return host_tags_


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


def return_to_bash(message, content=[]):
    """return to bash with message.

    Args:
        message (str): exit/reboot/seed/shutdown/update
        content (list, optional): content of the message. Defaults to [].
    """
    logger.info(f"host.return_to_bash({message}).")
    file.create(
        os.path.join(
            os.getenv("abcli_path_abcli", ""),
            f"abcli_host_return_to_bash_{message}",
        ),
        content,
    )


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
        output_filename = file.auxiliary(None, "txt")
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
        tensorflow_version = ""

    try:
        import tensorflow.keras as keras

        keras_version = "Keras {}".format(keras.__version__)
    except:
        keras_version = ""

    try:
        import tflite_runtime.interpreter as tflite

        tflite_version = "TensorFlow Lite"
    except:
        tflite_version = ""

    return [
        thing for thing in [tflite_version, tensorflow_version, keras_version] if thing
    ]
