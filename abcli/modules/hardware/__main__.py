import argparse
import time
from . import instance as hardware
from . import name
from ... import string
from ... import logging
import logging

logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="input/output",
)
parser.add_argument(
    "--outputs",
    type=str,
    default="",
)
args = parser.parse_args()

success = False
if args.task == "input":
    logger.info("loop started (Ctrl+C to stop)")
    # https://stackoverflow.com/a/18994932/10917551
    try:
        while True:
            logger.info(
                "inputs: {}".format(
                    ", ".join([str(hardware.input(pin)) for pin in hardware.input_pins])
                )
            )
            time.sleep(0.1)
    except KeyboardInterrupt:
        logger.info("Ctrl+C, stopping.")
    finally:
        hardware.release()
    success = True
elif args.task == "output":
    outputs = args.outputs + len(hardware.output_pins) * "1"
    for index, pin in enumerate(hardware.output_pins):
        hardware.output(pin, outputs[index] == "1")
    hardware.release()
    success = True
elif args.task == "validate":
    logger.info("loop started (Ctrl+C to stop)")
    value = True
    try:
        while True:
            activity = False
            for pin, pin_name in zip(
                [
                    hardware.green_switch_pin,
                    hardware.red_switch_pin,
                    hardware.switch_pin,
                    hardware.trigger_pin,
                ],
                "green_switch_pin,red_switch_pin,switch_pin,trigger_pin".split(","),
            ):
                if hardware.activated(pin):
                    logger.info(
                        "{}: {} activated.".format(
                            string.timestamp(ms=True),
                            pin_name,
                        )
                    )
                    activity = True

            for pin in hardware.output_pins:
                hardware.output(pin, activity or value)
            time.sleep(0.1)

            value = not value
    except KeyboardInterrupt:
        logger.info("Ctrl+C, stopping.")
    finally:
        hardware.release()
    success = True
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
