import pytest
from typing import Callable
from abcli.plugins.metadata import (
    get,
    post,
    get_from_file,
    get_from_object,
    get_from_path,
    post,
    post_to_file,
    post_to_object,
    post_to_path,
    MetadataSourceType,
)
from abcli.modules.objects import unique_object, object_path, path_of
from abcli.string import random_


@pytest.mark.parametrize(
    [
        "post_source",
        "post_source_type",
    ],
    [
        [
            lambda object_name: path_of(
                filename="metadata.yaml",
                object_name=object_name,
            ),
            MetadataSourceType.FILENAME,
        ],
        [
            lambda object_name: object_name,
            MetadataSourceType.OBJECT,
        ],
        [
            lambda object_name: object_path(
                object_name=object_name,
                create=True,
            ),
            MetadataSourceType.PATH,
        ],
    ],
)
@pytest.mark.parametrize(
    [
        "get_source",
        "get_source_type",
    ],
    [
        [
            lambda object_name: path_of(
                filename="metadata.yaml",
                object_name=object_name,
            ),
            MetadataSourceType.FILENAME,
        ],
        [
            lambda object_name: object_name,
            MetadataSourceType.OBJECT,
        ],
        [
            lambda object_name: object_path(
                object_name=object_name,
                create=True,
            ),
            MetadataSourceType.PATH,
        ],
    ],
)
def test_metadata(
    post_source: Callable[[str], str],
    post_source_type: MetadataSourceType,
    get_source: Callable[[str], str],
    get_source_type: MetadataSourceType,
):
    object_name = unique_object()
    key = random_()
    value = random_()

    assert post(
        key=key,
        value=value,
        source=post_source(object_name),
        source_type=post_source_type,
    )

    returned_value = get(
        key=key,
        source=get_source(object_name),
        source_type=get_source_type,
    )

    assert value == returned_value


def test_metadata_dict():
    object_name = unique_object()
    key = random_()
    value = {random_(): random_() for _ in range(10)}

    assert post(
        key=key,
        value=value,
        source=object_name,
        source_type=MetadataSourceType.OBJECT,
    )

    assert (
        get(
            key=key,
            source=object_name,
            source_type=MetadataSourceType.OBJECT,
        )
        == value
    )

    assert sorted(
        get(
            key=key,
            source=object_name,
            source_type=MetadataSourceType.OBJECT,
            dict_keys=True,
        )
    ) == sorted(value.keys())

    assert sorted(
        get(
            key=key,
            source=object_name,
            source_type=MetadataSourceType.OBJECT,
            dict_values=True,
        )
    ) == sorted(value.values())


def test_metadata_file():
    object_name = unique_object()
    key = random_()
    value = random_()

    filename = path_of(
        filename="metadata.yaml",
        object_name=object_name,
    )

    assert post_to_file(filename, key, value)

    assert get_from_file(filename, key) == value


def test_metadata_object():
    object_name = unique_object()
    key = random_()
    value = random_()

    assert post_to_object(object_name, key, value)

    assert get_from_object(object_name, key) == value


def test_metadata_path():
    object_name = unique_object()
    key = random_()
    value = random_()

    path = object_path(object_name=object_name, create=True)

    assert post_to_path(path, key, value)

    assert get_from_path(path, key) == value
