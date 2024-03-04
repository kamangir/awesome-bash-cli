import os
from abcli import env, file, path, string
from abcli.plugins.storage import instance as storage
from abcli.logger import logger


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
                env.abcli_object_root,
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
        env.abcli_object_root,
        env.abcli_object_name if object_name == "." else object_name,
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
    env.abcli_object_name = object_name

    path = object_path(object_name)
    os.environ["abcli_object_path"] = path
    env.abcli_object_path = path


def signature(info=None, object_name="."):
    return [
        "{}{}".format(
            env.abcli_object_name if object_name == "." else object_name,
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
