import math
import time
from abcli.modules import host
from abcli import logging
import logging

logger = logging.getLogger(__name__)


class Hardware(object):
    def __init__(self):
        logger.info(f"{self.__class__.__name__} initialized.")

        self.hat = host.cookie.get("hardware.hat", "led_switch")

        self.switch_pin = -1

        self.green_switch_pin = -1
        self.red_switch_pin = -1
        self.trigger_pin = -1

        self.looper_pin = -1  # red led
        self.incoming_pin = -1  # yellow led
        self.data_pin = -1  # green led
        self.outgoing_pin = -1  # blue led

        self.green_led_pin = -1
        self.red_led_pin = -1

        self.base_led_frequency = 10

        self.history = {}

    def activated(self, pin):
        """
        is pin activated?
        :param pin: pin number
        :return: True / False
        """
        if pin == -1:
            return False

        if self.hat != "led_switch":
            return False

        if pin in [
            self.switch_pin,
            self.green_switch_pin,
            self.red_switch_pin,
        ]:
            return self.input(pin) == False

        if pin in [
            self.trigger_pin,
        ]:
            return self.input(pin) == False

        return False

    def input(self, pin):
        """
        read pin input.
        :param pin: pin number
        :return: True / False
        """
        return True

    @property
    def input_pins(self):
        return [
            pin
            for pin in [
                self.switch_pin,
                self.green_switch_pin,
                self.red_switch_pin,
                self.trigger_pin,
            ]
            if pin != -1
        ]

    def output(self, pin, output):
        """
        set pin to ouput
        :param pin: pin number
        :param output: True / False
        :return: self
        """
        return self

    @property
    def output_pins(self):
        return [
            pin
            for pin in [
                self.looper_pin,
                self.incoming_pin,
                self.data_pin,
                self.outgoing_pin,
                self.green_led_pin,
                self.red_led_pin,
            ]
            if pin != -1
        ]

    def pulse(self, pin=None, frequency=None):
        """
        pulse pin
        :param pin: pin number / "outputs"
        :param frequency: frequency
        :return: self
        """
        if pin == "outputs":
            for index, pin in enumerate(self.output_pins):
                self.pulse(pin, index)

            return self

        if pin is None:
            for pin in self.output_pins:
                self.pulse(pin, frequency)

            return self

        self.history[pin] = (
            not bool(self.history.get(pin, False))
            if frequency is None
            else (lambda x: x - math.floor(x))(
                time.time() * (self.base_led_frequency + frequency)
            )
            >= 0.5
        )

        return self.output(pin, self.history[pin])

    def release(self):
        """
        release self
        :return: self
        """
        return self

    def setup(self, pin, what, pull_up_down=None):
        """
        Set up pin.
        :param pin: pin number
        :param what: "input" / "output"
        :return: self
        """
        return self


class RPi_or_Jetson(Hardware):
    def __init__(self, is_rpi=True):
        super(RPi_or_Jetson, self).__init__()

        self.is_rpi = is_rpi

        if self.is_rpi:
            import RPi.GPIO as GPIO

            self.switch_pin = 12

            self.green_switch_pin = 16
            self.red_switch_pin = 13

            self.looper_pin = 22  # red led
            self.incoming_pin = 18  # yellow led
            self.data_pin = 36  # green led
            self.outgoing_pin = 40  # blue led

            self.green_led_pin = 15
            self.red_led_pin = 7

            GPIO.setmode(GPIO.BOARD)  # numbers GPIOs by physical location
        elif self.hat == "led_switch":
            import Jetson.GPIO as GPIO

            self.switch_pin = 7

            self.trigger_pin = 12
            self.looper_pin = 29  # red led
            self.incoming_pin = 31  # yellow led
            self.data_pin = 32  # green led
            self.outgoing_pin = 33  # blue led

            GPIO.setmode(GPIO.BOARD)  # numbers GPIOs by physical location

        # http://razzpisampler.oreilly.com/ch07.html
        for pin in self.input_pins:
            self.setup(pin, "input", GPIO.PUD_UP)

        for pin in self.output_pins:
            self.setup(pin, "output")
            self.output(pin, False)

    def input(self, pin):
        if pin == -1:
            return True

        if self.is_rpi:
            import RPi.GPIO as GPIO
        else:
            import Jetson.GPIO as GPIO

        return GPIO.input(pin) == GPIO.HIGH

    def output(self, pin, output):
        if pin == -1:
            return self

        if self.is_rpi:
            import RPi.GPIO as GPIO
        else:
            import Jetson.GPIO as GPIO

        GPIO.output(pin, GPIO.HIGH if output else GPIO.LOW)
        return self

    def release(self):
        if self.is_rpi:
            import RPi.GPIO as GPIO
        else:
            import Jetson.GPIO as GPIO
        logger.info(f"{self.__class__.__name__}.release()")

        GPIO.cleanup()

        return self

    def setup(self, pin, what, pull_up_down=None):
        if pin == -1:
            return self

        if self.is_rpi:
            import RPi.GPIO as GPIO
        else:
            import Jetson.GPIO as GPIO

        if what == "output":
            what = GPIO.OUT
        elif what == "input":
            what = GPIO.IN
        else:
            raise NameError(
                f"{self.__class__.__name__}.setup({pin}): unknown what: {what}."
            )

        if pull_up_down is None:
            GPIO.setup(pin, what)
        else:
            GPIO.setup(pin, what, pull_up_down=pull_up_down)

        return self


class Jetson(RPi_or_Jetson):
    def __init__(self):
        super(Jetson, self).__init__(False)


class RPi(RPi_or_Jetson):
    def __init__(self):
        super(RPi, self).__init__(True)
