import cv2
import numpy as np
import os
from abcli import file
from abcli import fullname
from abcli.modules import objects
from abcli.modules import host
from abcli.plugins import graphics
from . import NAME
from abcli.logging import crash_report
import abcli.logging
import logging

logger = logging.getLogger(__name__)


class Display(object):
    def __init__(self):
        self.fullscreen = host.cookie.get("display.fullscreen", True)

        self.canvas = None
        self.notifications = []
        self.canvas_size = (640, 480)

        self.key_buffer = []

        self.title = fullname()

        self.created = False

    def create(self):
        if self.created:
            return
        self.created = True

        logger.info(f"{NAME}.create()")

        if self.fullscreen and not host.is_mac():
            # https://stackoverflow.com/a/34337534
            cv2.namedWindow(self.title, cv2.WND_PROP_FULLSCREEN)
            cv2.setWindowProperty(
                self.title, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN
            )

            self.canvas_size = (
                graphics.screen_width,
                graphics.screen_height,
            )
        else:
            cv2.namedWindow(self.title, cv2.WINDOW_NORMAL)
            cv2.resizeWindow(
                self.title,
                self.canvas_size[0],
                self.canvas_size[1],
            )

    def pressed(self, keys):
        output = bool([key for key in keys if key in self.key_buffer])

        self.key_buffer = [key for key in self.key_buffer if key not in keys]

        return output

    def save(self, filename=""):
        """save self.

        Args:
            filename (str, optional): filename. Defaults to "".

        Returns:
            bool: success.
        """
        if self.canvas is None:
            return ""

        if not filename:
            filename = file.auxiliary("display", "jpg")

        return filename if file.save_image(filename, self.canvas) else ""

    def show(
        self, image, header=[], sidebar=[], as_file=False, on_screen=False, sign=True
    ):
        """
        show
        :param image: image
        :param header: header
        :param sidebar: sidebar
        :param options:
            . as_file   : save as file
                       default : False
            . on_screen : show on screen
                       default : False
            . sign   : sign image.
                       default : True
        :return: self
        """
        self.notifications = self.notifications[-5:]

        if not as_file and not on_screen:
            return self

        self.canvas = np.copy(image)

        if sign:
            self.canvas = graphics.add_signature(
                self.canvas,
                self.signature() + header,
            )

            self.canvas = graphics.add_sidebar(
                self.canvas,
                sidebar,
                self.notifications,
            )

        if as_file:
            self.save()

        if on_screen:
            self.create()

            try:
                if len(self.canvas.shape) == 2:
                    self.canvas = np.stack(3 * [self.canvas], axis=2)

                cv2.imshow(
                    self.title,
                    cv2.cvtColor(
                        cv2.resize(
                            self.canvas,
                            dsize=self.canvas_size,
                            interpolation=cv2.INTER_LINEAR,
                        ),
                        cv2.COLOR_BGR2RGB,
                    ),
                )
            except:
                crash_report(f"{NAME}.show() failed.")

            key = cv2.waitKey(1)
            if key not in [-1, 255]:
                key = chr(key).lower()
                logger.info("display.show(): key press detected: '{}'".format(key))
                self.key_buffer.append(key)

        return self

    def signature(self):
        return [
            " | ".join(host.signature()),
            " | ".join(objects.signature()),
        ]
