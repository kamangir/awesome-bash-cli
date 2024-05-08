import pytest
import glob
from abcli.plugins.graphics.gif import generate_animated_gif
from abcli.plugins.testing import download_object
from abcli.modules import objects


@pytest.mark.parametrize(
    ["object_name"],
    [
        ["void"],
        ["2024-05-07-18-45-13-31678"],
    ],
)
def test_generate_animated_gif(object_name: str):
    assert download_object(object_name)

    list_of_images = list(glob.glob(objects.path_of("*.png", object_name)))
    if object_name != "void":
        assert list_of_images

    assert generate_animated_gif(
        list_of_images,
        objects.path_of("test.gif", object_name),
    )
