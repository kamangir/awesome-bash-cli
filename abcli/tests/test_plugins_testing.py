from abcli.plugins import testing
import pytest
from abcli import file
from abcli.modules import objects
from abcli import env
from abcli.plugins.testing import download_object


@pytest.mark.parametrize(
    ["object_name"],
    [
        [env.VANWATCH_TEST_OBJECT],
    ],
)
def test_download_object(object_name):
    assert download_object(object_name)

    list_of_files = [
        file.name_and_extension(filename)
        for filename in objects.list_of_files(object_name=object_name)
    ]

    assert "vancouver.json" in list_of_files, objects.path_of(
        object_name=object_name,
        filename="vancouver.json",
    )

    assert file.exist(
        objects.path_of(
            object_name=object_name,
            filename="vancouver.json",
        )
    )
