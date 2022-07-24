import os
import os.path
from .. import *
from .. import path
from .. import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.plugins"


def list_of_external(repo_names=False):
    """return list of external plugins.

    Args:
        repo_names (bool, optional): return repo names. Defaults to False.

    Returns:
        list[str]: list of external plugins.
    """

    abcli_path_git = os.getenv("abcli_path_git")

    output = [
        repo_name
        for repo_name in [
            path.name(path_)
            for path_ in path.list_of(abcli_path_git)
            if path.exist(os.path.join(path_, "abcli"))
        ]
        if repo_name != "awesome-bash-cli"
    ]

    if not repo_names:
        output = [repo_name.replace("-", "_") for repo_name in output]

    return output
