import os

NAME = "awesome_bash_cli"

VERSION = "1.929.1"

DESCRIPTION = "a framework for quickly building awesome bash cli's for machine vision/deep learning."


def fullname():
    return f"abcli-{VERSION}-{os.getenv('abcli_git_branch')}"


LOG_ON = 1
LOG_ALL = 2
log_level = LOG_ON

PLOT_ON = 1
PLOT_ALL = 2
plot_level = PLOT_ON
