import os
import os.path
from ... import *
from ... import file
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.plugins.aws"


def get_from_json(thing, default={}):
    """get info from config/aws.json.

    Args:
        thing (str): thing.
        default (Any, optional): default. Defaults to {}.

    Returns:
        Any: aws.json[thing]
    """
    success, content = file.load_json(os.path.join(os.getenv(), ""))
    if not success:
        return default

    return content.get(thing, default)
