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
        ["@bash /home/pi/git/abcli/bash/main.sh listen"],
    )


def poster(filename):
    import numpy as np
    from ...plugins import graphics

    logger.debug("terraform.poster({})".format(filename))

    image = graphics.add_frame(
        np.concatenate(
            [
                graphics.render_text(
                    None,
                    line,
                    {
                        "centered": True,
                        "image_width": graphics.screen_width,
                        "thickness": 4,
                    },
                )
                for line in signature()
            ],
            axis=0,
        ),
        32,
    )

    return (
        file.save_image(filename, image, "~archive") if filename is not None else image
    )


def mac(user):
    return terraform(
        ["/Users/{}/.bash_profile".format(user)],
        ["source ~/git/abcli/bash/main.sh"],
    )


def rpi(user, is_lite=False):
    success = terraform(
        ["/home/pi/.bashrc"],
        ["source /home/pi/git/abcli/bash/main.sh"],
    )

    if not is_lite:
        if not terraform(
            ["/etc/xdg/lxsession/LXDE-pi/autostart"],
            ["@bash /home/pi/git/abcli/bash/main.sh listen"],
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
            string
            for string in content
            if ("git/awesome-bash-cli" not in string) and string
        ] + [command]

        if "|".join(content) == "|".join(content_updated + [""]):
            logger.info("validated {}".format(filename))
        else:
            if file.save_text(filename, content_updated, "~archive"):
                logger.info("updated {}".format(filename))
            else:
                success = False

    return success


def signature():
    import platform
    from .. import host

    return [
        fullname(),
        " | ".join(host.tags + [host.name]),
        " | ".join(
            host.tensor_processing_signature()
            + [
                "Python {}".format(platform.python_version()),
                "{} {}".format(platform.system(), platform.release()),
            ]
        ),
        " | ".join(
            [string.pretty_date("date,~time"), string.pretty_date("~date,time,zone")]
            + (lambda x: [x] if x else [])(os.getenv("bolt_wifi_ssid", ""))
        ),
    ]


def ubuntu(user):
    return terraform(
        ["/home/{}/.bashrc".format(user)],
        ["source /home/{}/git/abcli/bash/main.sh".format(user)],
    )
