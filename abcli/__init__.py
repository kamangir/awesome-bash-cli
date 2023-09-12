import os

NAME = "abcli"

VERSION = "7.2315.1"


def fullname():
    return f"abcli-{VERSION}-{os.getenv('abcli_git_branch','unknown')}"


LOG_ON = 1
LOG_ALL = 2
log_level = LOG_ON

PLOT_ON = 1
PLOT_ALL = 2
plot_level = PLOT_ON
