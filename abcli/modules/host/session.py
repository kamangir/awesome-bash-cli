import time
from abcli import VERSION
from abcli.modules.display import instance as display
from abcli import file
from abcli.modules.hardware import instance as hardware
from abcli.plugins.message.messenger import instance as messenger
from abcli.modules import host
from abcli import string
from abcli.timer import Timer
from . import COOKIE
from .functions import *
from abcli.logging import crash_report
from abcli import logging
import logging

logger = logging.getLogger(__name__)


class Session(object):
    def __init__(self):
        super(Session, self).__init__()

        self.keys = {
            "e": "exit",
            "r": "reboot",
            "s": "shutdown",
            "u": "update",
        }

        self.messages = []

        self.model = None

        self.params = {"iteration": -1}

        self.state = {}

        self.switch_on_time = None

        self.timer = {}
        for name, period in {
            "display": 4,
            "messenger": 60,
            "reboot": 60 * 60 * 4,
            "temperature": 300,
        }.items():
            self.add_timer(name, period)

    def add_timer(self, name, period):
        if name not in self.timer:
            period = COOKIE.get("host.session.{}.period".format(name), period)
            self.timer[name] = Timer(period, name)
            logger.info(
                "host.session: timer[{}]:{}".format(
                    name, string.pretty_frequency(1 / period)
                )
            )
            return True
        return False

    def check_keyboard(self):
        for key in display.key_buffer:
            if key in self.keys:
                return_to_bash(self.keys[key])
                return False

        if " " in display.key_buffer:
            self.capture_command = "forced"

        display.key_buffer = []

        return None

    def check_messages(self):
        self.messages = []

        if not self.timer["messenger"].tick():
            return None

        _, self.messages = messenger.request()
        if self.messages:
            hardware.pulse(hardware.incoming_pin)

        for message in self.messages:
            output = self.process_message(message)
            if output in [True, False]:
                return output

        return None

    def process_message(self, message):
        if message.event == "capture":
            logger.info("host.session: capture message received.")
            self.capture_command = "forced"

        if message.event in "reboot,shutdown".split(","):
            logger.info(f"host.session: {message.event} message received.")
            return_to_bash(message.event)
            return False

        if message.event == "update":
            try:
                if message.data["version"] > VERSION:
                    return_to_bash("update")
                    return False
            except:
                crash_report("looper.process_message() bad update message")

        return None

    def check_seed(self):
        seed_filename = get_seed_filename()
        if not file.exist(seed_filename):
            return None

        success, content = file.load_json(f"{seed_filename}.json")
        if not success:
            return None

        hardware.pulse("outputs")

        seed_version = content.get("version", "")
        if seed_version <= VERSION:
            return None

        logger.info(f"host.session: seed {seed_version} detected.")
        return_to_bash("seed", [seed_filename])
        return False

    def check_switch(self):
        if hardware.activated(hardware.switch_pin):
            if self.switch_on_time is None:
                self.switch_on_time = time.time()
                logger.info("host.session: switch_on_time was set.")
        else:
            self.switch_on_time = None

        if self.switch_on_time is not None:
            hardware.pulse("outputs")

            if time.time() - self.switch_on_time > 10:
                return_to_bash("shutdown")
                return False
            else:
                return True

        return None

    def check_timers(self):
        if self.timer["display"].tick():
            display.show(
                self.frame_image,
                self.signature(),
                string.pretty_param(self.params),
            )

        if self.timer["reboot"].tick("wait"):
            return_to_bash("reboot")
            return False

        if self.timer["temperature"].tick():
            self.read_temperature()

        return None

    def close(self):
        hardware.release()

    # https://www.cyberciti.biz/faq/linux-find-out-raspberry-pi-gpu-and-arm-cpu-temperature-command/
    def read_temperature(self):
        if not host.is_rpi():
            return

        params = {}

        success, output = file.load_text("/sys/class/thermal/thermal_zone0/temp")
        if success:
            output = [thing for thing in output if thing]
            if output:
                try:
                    params["temperature.cpu"] = float(output[0]) / 1000
                except:
                    crash_report("looper.read_temperature(cpu) failed")
                    return

        self.params.update(params)
        logger.info("host.session: {}".format(", ".join(string.pretty_param(params))))

    def signature_(self):
        return (
            sorted([timer.signature() for timer in self.timer.values()])
            + (["*"] if self.new_frame else [])
            + (["^"] if self.auto_upload else [])
            + ([">{}".format(self.outbound_queue)] if self.outbound_queue else [])
            + (["hat:{}".format(hardware.hat)] if hardware.hat else [])
            + (
                [
                    "switch:{}".format(
                        string.pretty_time(
                            time.time() - self.switch_on_time, "largest,short"
                        )
                    )
                ]
                if self.switch_on_time is not None
                else []
            )
        )

    def signature(self):
        return [" | ".join(self.signature_())] + (
            [] if self.model is None else [" | ".join(self.model.signature())]
        )

    def step(
        self,
        keyboard=True,
        messages=True,
        seed=True,
        switch=True,
        timers=True,
    ):
        self.params["iteration"] += 1

        hardware.pulse(hardware.looper_pin, 0)

        for enabled, step_ in zip(
            [
                keyboard,
                messages,
                timers,
                switch,
                seed,
            ],
            [
                self.check_keyboard,
                self.check_messages,
                self.check_timers,
                self.check_switch,
                self.check_seed,
            ],
        ):
            if not enabled:
                continue
            output = step_()
            if output in [False, True]:
                return output

        self.check_camera()

        return True
