from typing import List

from blue_options.terminal import show_usage


def help_get_module_name(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@plugins",
            "get_module_name",
            "<repo-name>",
        ],
        "get module name for <repo-name>.",
        mono=mono,
    )


def help_install(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@plugins",
            "install",
            "[all | <plugin-name>]",
        ],
        "install plugin(s).",
        mono=mono,
    )


def help_list_of_external(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@plugins",
            "list_of_external",
        ],
        "show list of external plugins.",
        mono=mono,
    )


def help_list_of_installed(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@plugins",
            "list_of_installed",
        ],
        "show list of installed plugins.",
        mono=mono,
    )


def help_transform(
    tokens: List[str],
    mono: bool,
) -> str:
    return show_usage(
        [
            "@plugins",
            "transform",
            "<repo-name>",
        ],
        "transform a blue-plugin git clone to <repo-name>.",
        mono=mono,
    )


help_functions = {
    "get_module_name": help_get_module_name,
    "install": help_install,
    "list_of_external": help_list_of_external,
    "list_of_installed": help_list_of_installed,
    "transform": help_transform,
}
