import os
from abcli import file


def get_from_json(thing, default={}):
    """get info from config/aws.json.

    Args:
        thing (str): thing.
        default (Any, optional): default. Defaults to {}.

    Returns:
        Any: aws.json[thing]
    """
    success, content = file.load_json(
        os.path.join(
            os.getenv("abcli_path_bash"),
            "bootstrap/config/aws.json",
        )
    )
    if not success:
        return default

    return content.get(thing, default) if thing else content
