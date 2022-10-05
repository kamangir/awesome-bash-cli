import os
from abcli import file, string
from abcli.plugins.storage import instance as storage


def list_of_files(object_name, cloud=False, **kwargs):
    """return list of files in object_name.

    Args:
        object_name (str): object name.
        cloud (bool, optional): on cloud. Defaults to False.

    Returns:
        List[str]: list of files.
    """
    return (
        storage.list_of_objects(
            object_name,
            **kwargs,
        )
        if cloud
        else file.list_of(
            os.path.join(
                os.getenv("abcli_object_root", ""),
                object_name,
            ),
            **kwargs,
        )
    )


def signature(info=None):
    return [
        "{}{}".format(
            os.getenv("abcli_object_name", ""),
            "" if info is None else f"/{str(info)}",
        ),
        string.pretty_date(include_time=False),
        string.pretty_date(include_date=False, include_zone=True),
    ]
