import os
from ... import fullname, shortname
from ... import file
from ... import string
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.file"


def lxde(user):
    return terraform(
        ["/etc/xdg/lxsession/LXDE/autostart"],
        ["@bash /home/pi/git/abcli/bash/main.sh start_session"],
    )


def poster(filename):
    """generate background poster.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    import numpy as np
    from ...plugins import graphics

    logger.debug("terraform.poster({})".format(filename))

    image = graphics.add_frame(
        np.concatenate(
            [
                graphics.render_text(
                    centered=True,
                    image_width=graphics.screen_width,
                    text=line,
                    thickness=4,
                )
                for line in signature()
            ],
            axis=0,
        ),
        32,
    )

    return image if filename is None else file.save_image(filename, image)


def mac(user):
    return terraform(
        ["/Users/{}/.bash_profile".format(user)],
        ["source ~/git/abcli/bash/main.sh"],
    )


def rpi(user, is_headless=False):
    success = terraform(
        ["/home/pi/.bashrc"],
        ["source /home/pi/git/abcli/bash/main.sh"],
    )

    if not is_headless:
        if not terraform(
            ["/etc/xdg/lxsession/LXDE-pi/autostart"],
            ["@bash /home/pi/git/abcli/bash/main.sh start_session"],
        ):
            success = False

    return success


def terraform(filenames, commands):
    success = True
    for filename, command in zip(
        filenames,
        commands,
    ):
        success_, content = file.load_text(filename)
        if not success_:
            success = False
            continue

        content_updated = [
            string for string in content if ("git/abcli" not in string) and string
        ] + [command]

        if not file.save_text(
            filename,
            content_updated,
            if_different=True,
            log=True,
        ):
            success = False

    return success


def signature():
    import platform
    from .. import host

    return [
        fullname(),
        host.get_name(),
        " | ".join(
            host.tensor_processing_signature()
            + [
                f"Python {platform.python_version()}",
                f"{platform.system()} {platform.release()}",
            ]
        ),
        " | ".join(
            [
                string.pretty_date(include_time=False),
                string.pretty_date(
                    include_date=False,
                    include_zone=True,
                ),
            ]
            + (lambda x: [x] if x else [])(os.getenv("bolt_wifi_ssid", ""))
        ),
    ]


def ubuntu(user):
    return terraform(
        ["/home/{}/.bashrc".format(user)],
        ["source /home/{}/git/abcli/bash/main.sh".format(user)],
    )
