from typing import Any
from .enums import MetadataSourceType
from abcli import file


def get(
    key,
    default="",
    source=".",
    source_type: MetadataSourceType = MetadataSourceType.FILENAME,
    filename: str = "metadata.yaml",
    dict_keys: bool = False,
    dict_values: bool = False,
) -> Any:
    success, metadata = file.load_yaml(
        source_type.filename(source, filename),
        civilized=True,
    )
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


def get_from_file(
    filename: str,
    key,
    default="",
    **kwargs,
) -> Any:
    return get(
        key=key,
        default=default,
        source=filename,
        source_type=MetadataSourceType.FILENAME,
        **kwargs,
    )


def get_from_object(
    object_name: str,
    key,
    default="",
    **kwargs,
) -> Any:
    return get(
        key=key,
        default=default,
        source=object_name,
        source_type=MetadataSourceType.OBJECT,
        **kwargs,
    )


def get_from_path(
    path: str,
    key: str,
    default="",
    **kwargs,
) -> Any:
    return get(
        key=key,
        default=default,
        source=path,
        source_type=MetadataSourceType.PATH,
        **kwargs,
    )
