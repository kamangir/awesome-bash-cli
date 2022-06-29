import os

name = "awesome_bash_cli"

shortname = "abcli"

version = "1.1.147"

fullname = f"{shortname}-{version}-{os.getenv('abcli_git_branch')}"

description = "a framework for quickly building awesome bash cli's for machine vision/deep learning."
