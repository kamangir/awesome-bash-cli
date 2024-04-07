import os
from abcli import fullname
from abcli import env, file
from abcli import string
from . import HOST_NAME, HOST_TAGS, NAME
from abcli.logger import logger, crash_report


def get_name(cache=True):
    global HOST_NAME

    if cache and HOST_NAME is not None:
        return HOST_NAME

    HOST_NAME = get_name_()
    return HOST_NAME


def get_name_():
    default = string.random_(5)

    if is_docker():
        return os.getenv("abcli_container_id", default)

    if is_ec2():
        return os.getenv("abcli_ec2_instance_id", default)

    if is_jetson():
        return os.getenv("abcli_jetson_nano_serial_number", default)

    if is_ubuntu():
        return os.getenv("abcli_ubuntu_computer_id", default)

    if is_mac():
        return os.getenv("USER", default)

    if is_jupyter():
        return "Jupyter-Notebook"

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
        else (
            "/Volumes/seed/abcli/ubuntu.sh"
            if is_ubuntu()
            else "/media/pi/SEED/abcli/rpi.sh" if is_rpi() else ""
        )
    )


def get_tags(cache=True):
    from abcli.plugins import tags

    global HOST_TAGS

    if cache and HOST_TAGS is not None:
        return HOST_TAGS

    HOST_TAGS = tags.get(get_name(cache=cache))
    return HOST_TAGS


def is_aws_batch():
    return os.getenv("abcli_is_aws_batch", "false") == "true"


def is_docker():
    return os.getenv("abcli_is_docker", "false") == "true"


def is_ec2():
    return os.getenv("abcli_is_ec2", "false") == "true"


def is_github_workflow():
    return os.getenv("abcli_is_github_workflow", "false") == "true"


def is_headless():
    return os.getenv("abcli_is_headless", "false") == "true"


def is_jetson():
    return os.getenv("abcli_is_jetson", "false") == "true"


# https://github.com/ultralytics/yolov5/blob/master/utils/general.py#LL79C18-L79C18
def is_jupyter():
    """
    Check if the current script is running inside a Jupyter Notebook.
    Verified on Colab, Jupyterlab, Kaggle, Paperspace.
    Returns:
        bool: True if running inside a Jupyter Notebook, False otherwise.
    """
    try:
        from IPython import get_ipython

        return get_ipython() is not None
    except:
        return False


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
        + list(
            set(
                [
                    env.abcli_hostname,
                    get_name(),
                ]
            )
        )
        + tensor_processing_signature()
        + [
            "Python {}".format(platform.python_version()),
            "{} {}".format(platform.system(), platform.release()),
        ]
        + ([env.abcli_wifi_ssid] if env.abcli_wifi_ssid else [])
    )


def tensor_processing_signature():
    output = []

    try:
        import tensorflow

        output += [f"TensorFlow {tensorflow.__version__}"]
    except:
        pass

    try:
        from tensorflow import keras

        output += [f"Keras {keras.__version__}"]
    except:
        pass

    try:
        import tflite_runtime.interpreter as tflite

        output += ["TensorFlow Lite"]
    except:
        pass

    try:
        import torch

        output += [f"torch-{torch.__version__}"]
    except:
        pass

    return output
