import os

name = "awesome_bash_cli"

shortname = "abcli"

version = "1.1.134"

fullname = f"{shortname}-{version}-{os.getenv('bolt_git_branch')}"

description = "a framework for quickly building awesome bash cli's."
