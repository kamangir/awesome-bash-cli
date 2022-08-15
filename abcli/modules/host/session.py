import copy
from . import arguments
from ...modules import terraform
from ... import string
from ...timer import Timer
from ... import logging
import logging

logger = logging.getLogger(__name__)


class Session(object):
    def __init__(self, options=""):
        super(Session, self).__init__()

        self.keys = {
            "e": "exit",
            "r": "reboot",
            "s": "shutdown",
            "u": "update",
        }

        self.capture_command = ""

        self.new_frame = False
        self.frame_image = terraform.poster(None)
        self.frame_filename = ""

        self.external_messages = []

        self.model = None

        self.options = copy.deepcopy(options)

        self.params = {"iteration": -1}

        self.state = {}

        self.switch_on_time = None

        self.timer = {}
        for name, period in {
            "capture": 60 * 5,
            "display": 4,
            "messenger": 60,
            "reboot": 60 * 60 * 4,
            "temperature": 300,
        }.items():
            self.add_timer(name, period)

        self.auto_upload = arguments.get("looper.auto_upload", True)
        self.outbound_queue = arguments.get("looper.outbound_queue", "stream")
        self.do_annotate = arguments.get("looper.capture.annotate", True)
        self.capture_enabled = arguments.get("looper.capture.enabled", True)

    def add_timer(self, name, period):
        if name not in self.timer:
            period = arguments.get("looper.{}.period".format(name), period)
            self.timer[name] = Timer(period, name)
            logger.info(
                "looper.timer[{}]:{}".format(name, string.pretty_frequency(1 / period))
            )
            return True
        return False

    def check_camera(self):
        self.new_frame = False

        if not self.capture_command or not self.capture_enabled:
            return

        success, filename, image = camera.capture(self.capture_command)

        self.capture_command = ""

        if not filename or filename == "same" or not success:
            return

        hardware.pulse(hardware.data_pin)

        self.new_frame = True
        self.frame_image = image
        self.frame_filename = filename

        if self.do_annotate:
            camera.annotate()

        if self.outbound_queue:
            import abcli.message as message

            message.mail(self.frame_filename, self.outbound_queue)
        elif self.auto_upload:
            storage.upload_file(self.frame_filename)

    def check_keyboard(self):
        for key in display.key_buffer:
            if key in self.keys:
                host.return_to_bash(self.keys[key])
                return False

        if " " in display.key_buffer:
            self.capture_command = "forced"

        display.key_buffer = []

        return None

    def check_messages(self):
        self.external_messages = []

        if not self.timer["messenger"].tick():
            return None

        _, self.external_messages = messenger.request()
        if self.external_messages:
            hardware.pulse(hardware.incoming_pin)

        for message in self.external_messages:
            output = self.process_message(message)
            if output in [True, False]:
                return output

        return None

    def process_message(self, message):
        if message.event == "capture":
            logger.info("received capture command.")
            self.capture_command = "forced"

        if message.event in "reboot,shutdown".split(","):
            logger.info("{} message received.".format(message.event))
            host.return_to_bash(message.event)
            return False

        if message.event == "update":
            try:
                if message.data["revision"] > abcli.revision:
                    host.return_to_bash("update")
                    return False
            except:
                crash_report("looper.process_message() bad update message")

        return None

    def check_seed(self):
        seed_filename = host.get_seed_filename()
        if not file.exist(seed_filename):
            return None

        success, content = file.load_json(seed_filename + ".json")
        if not success:
            return None

        hardware.pulse("outputs")

        try:
            seed_revision = float(content.get("revision", 0.00))
        except:
            crash_report("looper.check_seed() bad seed")
            success = False
        if not success:
            return None

        if seed_revision <= abcli.revision:
            logger.debug(
                "seed {:.2f} ignored (<={:.2f}).".format(
                    seed_revision,
                    abcli.revision,
                )
            )
            return None

        logger.info("seed {:.2f} detected.".format(seed_revision))
        host.return_to_bash("seed", [seed_filename])
        return False

    def check_switch(self):
        if hardware.activated(hardware.switch_pin):
            if self.switch_on_time is None:
                self.switch_on_time = time.time()
                logger.info("looper.switch_on_time was set.")
        else:
            self.switch_on_time = None

        if self.switch_on_time is not None:
            hardware.pulse("outputs")

            if time.time() - self.switch_on_time > 10:
                host.return_to_bash("shutdown")
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
                self.options,
            )

        if self.timer["reboot"].tick("wait"):
            host.return_to_bash("reboot")
            return False

        if self.timer["temperature"].tick():
            self.read_temperature()

        return None

    def close(self):
        for tag in sorted(modules.keys()):
            if tag in host.tags:
                modules[tag].release(self)

        hardware.release()

    # https://www.cyberciti.biz/faq/linux-find-out-raspberry-pi-gpu-and-arm-cpu-temperature-command/
    def read_temperature(self, options=""):
        options = Options(options).default("cpu", True).default("gpu", False)

        if not host.is_rpi():
            return

        params = {}

        if options["cpu"]:
            success, output = file.load_text("/sys/class/thermal/thermal_zone0/temp")
            if success:
                output = [thing for thing in output if thing]
                if output:
                    try:
                        params["temperature.cpu"] = float(output[0]) / 1000
                    except:
                        crash_report("looper.read_temperature(cpu) failed")
                        return

        if options["gpu"]:
            success, output = host.shell(
                "/opt/vc/bin/vcgencmd measure_temp", "clean,output"
            )
            if success:
                output = [
                    thing
                    for thing in [string.between(thing, "=", "'") for thing in output]
                    if thing
                ]
                if output:
                    try:
                        params["temperature.gpu"] = float(output[0])
                    except:
                        crash_report("looper.read_temperature(gpu) failed")
                        return

        self.params.update(params)
        logger.info(
            "looper.read_temperature(): {}".format(
                ", ".join(string.pretty_param(params))
            )
        )

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

    def step(self, options=""):
        options = (
            Options(options)
            .default("keyboard", True)
            .default("messages", True)
            .default("seed", True)
            .default("switch", True)
            .default("timers", True)
        )
        self.params["iteration"] += 1

        hardware.pulse(hardware.looper_pin, 0)

        for enabled, step_ in zip(
            [
                options["keyboard"],
                options["messages"],
                options["timers"],
                options["switch"],
                options["seed"],
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

        for tag in sorted(modules.keys()):
            output = (
                modules[tag].step(self)
                if tag in host.tags
                else modules[tag].not_step(self)
            )
            if output in [False, True]:
                return output

        return True
