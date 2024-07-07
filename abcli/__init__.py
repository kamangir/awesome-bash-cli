import os

NAME = "abcli"

ICON = "🚀"

DESCRIPTION = f"{ICON} a language to speak AI."

VERSION = "9.154.1"

REPO_NAME = "awesome-bash-cli"

MARQUEE = "https://github.com/kamangir/awesome-bash-cli/raw/main/assets/marquee.png"


def fullname() -> str:
    abcli_git_branch = os.getenv("abcli_git_branch", "")
    return "abcli-{}{}".format(
        VERSION,
        f"-{abcli_git_branch}" if abcli_git_branch else "",
    )
