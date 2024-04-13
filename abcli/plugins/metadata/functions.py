import base64
import copy
from abcli import env
from enum import Enum, auto
import os
import os.path
from abcli import file
from . import NAME
from abcli.logger import logger


class MetadataSourceType(Enum):
    FILENAME = auto()
    OBJECT = auto()
    PATH = auto()

    def filename(self, source: str, filename="metadata.yaml"):
        if self == MetadataSourceType.FILENAME:
            return source

        if self == MetadataSourceType.OBJECT:
            from abcli.modules import objects

            return os.path.join(
                objects.object_path(source),
                filename,
            )

        if self == MetadataSourceType.PATH:
            return os.path.join(
                env.abcli_object_path if source == "." else source,
                filename,
            )

        return f"unknown-source-type:{self.name.lower()}"


def get(
    key,
    default="",
    source=".",
    source_type: MetadataSourceType = MetadataSourceType.FILENAME,
    dict_keys: bool = False,
    dict_values: bool = False,
    filename: str = "metadata.yaml",
):
    success, metadata = file.load_yaml(source_type.filename(source, filename))
    if not success:
        return default

    try:
        output = metadata
        for key_ in [key_ for key_ in key.split(".") if key_]:
            output = output.get(key_, default)

        if dict_keys:
            output = list(output.keys())
        elif dict_values:
            output = list(output.values())

        return output
    except Exception as e:
        return type(e).__name__


def post(
    key,
    value,
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
