from typing import Any
from .enums import MetadataSourceType
import base64
import copy
from abcli import file
from abcli.plugins import NAME
from abcli.logger import logger

NAME = f"{NAME}.metadata"


def post(
    key: str,
    value: Any,
    filename: str = "metadata.yaml",
    source=".",
    source_type: MetadataSourceType = MetadataSourceType.FILENAME,
    is_base64_encoded=False,
    verbose: bool = False,
) -> bool:
    if is_base64_encoded:
        value = str(base64.b64decode(value))

    filename = source_type.filename(source, filename)

    _, metadata = file.load_yaml(filename, civilized=True)

    metadata[key] = copy.deepcopy(value)

    logger.info(
        "{}.post[{}]: {}{}".format(
            NAME,
            filename,
            key,
            f"={value}" if verbose else "",
        )
    )

    return file.save_yaml(filename, metadata)


def post_to_file(
    filename: str,
    key: str,
    value: Any,
    **kwargs,
) -> bool:
    return post(
        key=key,
        value=value,
        source=filename,
        source_type=MetadataSourceType.FILENAME,
        **kwargs,
    )


def post_to_object(
    object_name: str,
    key: str,
    value: Any,
    **kwargs,
) -> bool:
    return post(
        key=key,
        value=value,
        source=object_name,
        source_type=MetadataSourceType.OBJECT,
        **kwargs,
    )


def post_to_path(
    path: str,
    key: str,
    value: Any,
    **kwargs,
) -> bool:
    return post(
        key=key,
        value=value,
        source=path,
        source_type=MetadataSourceType.PATH,
        **kwargs,
    )
