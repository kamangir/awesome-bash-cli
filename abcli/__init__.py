import os

NAME = "abcli"

VERSION = "8.186.1"

DESCRIPTION = "🚀 a language to speak AI."


def fullname() -> str:
    abcli_git_branch = os.getenv("abcli_git_branch", "")
    return "abcli-{}{}".format(
        VERSION,
        f"-{abcli_git_branch}" if abcli_git_branch else "",
    )
