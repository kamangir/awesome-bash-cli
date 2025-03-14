from typing import List

from blue_options.terminal import show_usage, xtra

instance_type_details = {
    "instance-type: t2.xlarge | p2.xlarge (gpu)": [],
}


def help_from_image(
    tokens: List[str],
    mono: bool,
) -> str:
    options = "image=<image-name>,ssh,vnc"

    return show_usage(
        [
            "@instance",
            "from_image",
            "<instance-type>",
            "<instance-name>",
            f"[{options}]",
        ],
        "create ec2 instance from <image-name>.",
        instance_type_details,
        mono=mono,
    )


def help_from_template(
    tokens: List[str],
    mono: bool,
) -> str:
    options = "ssh,vnc"

    return show_usage(
        [
            "@instance",
            "from_template",
            "<template-name>",
            "<instance-type>",
            "<instance-name>",
            f"[{options}]",
        ],
        "create ec2 instance from <template-name>.",
        instance_type_details,
        mono=mono,
    )


def help_get_ip(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@instance",
            "get_ip",
            "<instance-name>",
        ],
        "get <instance-name> ip address.",
        mono=mono,
    )


def help_list(
    tokens: List[str],
    mono: bool,
) -> str:
    options = "images | instances | templates"

    return show_usage(
        [
            "@instance",
            "list",
            f"[{options}]",
        ],
        "list.",
        mono=mono,
    )


def help_terminate(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@instance",
            "terminate",
            "<instance-id>",
        ],
        "terminate <instance-id>.",
        mono=mono,
    )


help_functions = {
    "from_image": help_from_image,
    "from_template": help_from_template,
    "get_ip": help_get_ip,
    "list": help_list,
    "terminate": help_terminate,
}
