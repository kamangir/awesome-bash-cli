"""awesome-bash-cli: 🚀 a language to speak AI.
"""

import os

NAME = "abcli"

VERSION = "7.2693.1"

DESCRIPTION = "🚀 a language to speak AI."


def fullname() -> str:
    """return full name.

    Returns:
        str: full name.
    """
    return f"abcli-{VERSION}-{os.getenv('abcli_git_branch','unknown')}"
