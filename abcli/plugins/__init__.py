import os
import os.path
from .. import *
from .. import file
from ..tasks import host
from .. import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.plugins"


def list_of_external(tagged=False):
    """return list of external plugins.

    Args:
        tagged (bool, optional): tagged. Defaults to False.

    Returns:
        list[str]: list of external plugins.
    """
    plugins = list(
        file.load_json(
            os.path.join(
                os.getenv("abcli_path_bash"),
                "bootstrap/config/external_plugins.json",
            ),
            civilized=True,
        )[1].keys()
    )

    if tagged:
        plugins = [plugin for plugin in plugins if plugin in host.get_tags()]

    return plugins
