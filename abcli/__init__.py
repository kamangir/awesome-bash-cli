import os

name = "awesome_bash_cli"

shortname = os.getenv("abcli_name")

version = "1.1.581"

description = "a framework for quickly building awesome bash cli's for machine vision/deep learning."


def fullname():
    return f"{shortname}-{version}-{os.getenv('abcli_git_branch')}"


LOG_ON = 1
LOG_ALL = 2
log_level = LOG_ON

PLOT_ON = 1
PLOT_ALL = 2
plot_level = PLOT_ON
