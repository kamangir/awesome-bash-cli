import pytest
import numpy as np
from abcli import file
from abcli.modules import objects
from abcli.plugins.graphics.signature import add_signature
from abcli import env
from abcli.plugins.testing import download_object


# https://www.randomtextgenerator.com/
dummy_text = "This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text. This is some dummy text."


@pytest.mark.parametrize(
    ["object_name"],
    [
        [env.VANWATCH_TEST_OBJECT],
    ],
)
def test_add_signature(object_name):
    assert download_object(object_name)

    success, image = file.load_image(
        objects.path_of(
            "Victoria41East.jpg",
            object_name,
        )
    )
    assert success

    output_image = add_signature(
        image,
        header=[dummy_text],
        footer=[dummy_text, dummy_text],
    )

    assert isinstance(output_image, np.ndarray)
