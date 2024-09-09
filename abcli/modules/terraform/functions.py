from blue_options import string
from blue_objects import file

from abcli import fullname
from abcli import env
from abcli.logger import logger


def lxde(_):
    return terraform(
        ["/etc/xdg/lxsession/LXDE/autostart"],
        [
            "@bash /home/pi/git/awesome-bash-cli/abcli/.abcli/abcli.sh - abcli session start"
        ],
    )


def poster(filename):
    """generate background poster.

    Args:
        filename (str): filename.

    Returns:
        bool: success.
    """
    import numpy as np
    from abcli.plugins import graphics

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
    from abcli.modules import host

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
            + ([env.abcli_wifi_ssid] if env.abcli_wifi_ssid else [])
        ),
    ]


def ubuntu(user):
    return terraform(
        ["/home/{}/.bashrc".format(user)],
        ["source /home/{}/git/awesome-bash-cli/abcli/.abcli/abcli.sh".format(user)],
    )
