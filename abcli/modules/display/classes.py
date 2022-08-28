import cv2
import numpy as np
import os
import abcli
from abcli.modules import objects
from abcli.modules import host
from abcli import file
from abcli.modules import host
from abcli.plugins import graphics
from . import NAME
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

        self.title = abcli.fullname()

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
            str: filename where save was saved.
        """

        if self.canvas is None:
            return ""

        if not filename:
            filename = file.auxiliary(self, "jpg")

        return filename if file.save_image(filename, self.canvas) else ""

    def show(
        self,
        image,
        header=[],
        sidebar=[],
        as_file=False,
        on_screen=False,
        sign=True,
    ):
        """_summary_

        Args:
            image (np.ndarray): image.
            header (list, optional): header. Defaults to [].
            sidebar (list, optional): sidebar. Defaults to [].
            as_file (bool, optional): save as file. Defaults to False.
            on_screen (bool, optional): show on screen. Defaults to False.
            sign (bool, optional): sign image. Defaults to True.

        Returns:
            Display(): self.
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
                from abcli.logging import crash_report

                crash_report(f"{NAME} failed.")

            key = cv2.waitKey(1)
            if key not in [-1, 255]:
                key = chr(key).lower()
                logger.info(f"{NAME}.show(): key press detected: '{key}'")
                self.key_buffer.append(key)

        return self

    def signature(self):
        return [
            " | ".join(host.signature()),
            " | ".join(objects.signature()),
        ]
