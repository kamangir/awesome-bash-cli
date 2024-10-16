from typing import List

from blue_options.terminal import show_usage, xtra


def help_pytest(
    tokens: List[str],
    mono: bool,
    plugin_name: str = "abcli",
) -> str:
    options = "".join(
        [
            "list",
            xtra(
                ",dryrun,~log,show_warning,~verbose",
                mono=mono,
            ),
        ]
    )

    callable = f"{plugin_name} pytest"

    if plugin_name == "abcli":
        options = f"{options},plugin=<plugin-name>"
        callable = "@pytest"

    return show_usage(
        callable.split(" ")
        + [
            f"[{options}]",
            "[filename.py|filename.py::test]",
        ],
        f"pytest {plugin_name}.",
        mono=mono,
    )


help_functions = {
    "pytest": help_pytest,
}
