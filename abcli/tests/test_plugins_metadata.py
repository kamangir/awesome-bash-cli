import pytest
from typing import Callable
from abcli.plugins.metadata.functions import get, post, MetadataSourceType
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
