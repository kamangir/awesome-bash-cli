import os
import os.path
from .. import *
from .. import file
from .. import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.plugins"


def list_of_external():
    """return list of external plugins.

    Returns:
        list[str]: list of external plugins.
    """
    return list(
        file.load_json(
            os.path.join(
                os.getenv("bolt_path_bash"),
                "plugins/external.json",
            ),
            civilized=True,
        )[1].keys()
    )
