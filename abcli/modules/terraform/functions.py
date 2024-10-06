from typing import List

import numpy as np
import platform

from blueness import module
from blue_options import host, string
from blue_options.env import abcli_wifi_ssid
from blue_objects import file
from blue_objects.graphics import screen
from blue_objects.graphics.frame import add_frame
from blue_objects.graphics.text import render_text

from abcli import NAME, fullname
from abcli.logger import logger

NAME = module.name(__file__, NAME)


def lxde(_):
    return terraform(
        ["/etc/xdg/lxsession/LXDE/autostart"],
        [
            "@bash /home/pi/git/awesome-bash-cli/abcli/.abcli/abcli.sh - abcli session start"
        ],
    )


def poster(filename: str) -> bool:
    logger.debug("{}.poster({})".format(NAME, filename))

    image = add_frame(
        np.concatenate(
            [
                render_text(
                    centered=True,
                    image_width=screen.get_size()[1],
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
        ["source ~/git/awesome-bash-cli/abcli/.abcli/abcli.sh"],
    )


def rpi(_, is_headless=False):
    success = terraform(
        ["/home/pi/.bashrc"],
        [
            "source /home/pi/git/awesome-bash-cli/abcli/.abcli/abcli.sh{}".format(
                "  - abcli session start" if is_headless else ""
            )
        ],
    )

    if not is_headless:
        if not terraform(
            ["/etc/xdg/lxsession/LXDE-pi/autostart"],
            [
                "@bash /home/pi/git/awesome-bash-cli/abcli/.abcli/abcli.sh  - abcli session start"
            ],
        ):
            success = False

    return success


def terraform(
    filenames: List[str],
    commands: List[str],
) -> bool:
    success = True
    for filename, command in zip(filenames, commands):
        success_, content = file.load_text(filename)
        if not success_:
            success = False
            continue

        content_updated = [
            string
            for string in content
            if ("git/awesome-bash-cli" not in string) and string
        ] + [command]

        if not file.save_text(
            filename,
            content_updated,
            if_different=True,
            log=True,
        ):
            success = False

    return success


def signature() -> List[str]:
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
            + ([abcli_wifi_ssid] if abcli_wifi_ssid else [])
        ),
    ]


def ubuntu(user):
    return terraform(
        ["/home/{}/.bashrc".format(user)],
        ["source /home/{}/git/awesome-bash-cli/abcli/.abcli/abcli.sh".format(user)],
    )
