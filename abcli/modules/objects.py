import os
from abcli import file, path, string
from abcli.plugins.storage import instance as storage
from abcli import logging
import logging

logger = logging.getLogger(__name__)

abcli_object_root = os.getenv(
    "abcli_object_root",
    os.path.join(
        os.getenv("HOME"),
        "storage/abcli",
    ),
)


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
                abcli_object_root,
                object_name,
                "*",
            ),
            **kwargs,
        )
    )


def object_path(
    object_name=".",
    create=False,
):
    output = os.path.join(
        abcli_object_root,
        os.getenv(
            "abcli_object_name",
            "",
        )
        if object_name == "."
        else object_name,
    )

    if create:
        os.makedirs(output, exist_ok=True)

    return output


def path_of(
    filename,
    object_name=".",
    create=False,
):
    return os.path.join(
        object_path(object_name, create),
        filename,
    )


def select(object_name: str):
    os.environ["abcli_object_name"] = object_name
    os.environ["abcli_object_path"] = object_path(object_name)


def signature(info=None, object_name="."):
    return [
        "{}{}".format(
            os.getenv("abcli_object_name", "") if object_name == "." else object_name,
            "" if info is None else f"/{str(info)}",
        ),
        string.pretty_date(include_time=False),
        string.pretty_date(include_date=False, include_zone=True),
    ]


def unique_object(prefix=""):
    object_name = string.pretty_date(
        as_filename=True,
        unique=True,
    )
    if prefix:
        object_name = f"{prefix}-{object_name}"

    path.create(object_path(object_name))

    logger.info(f"📂 {object_name}")

    return object_name
