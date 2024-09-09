from blue_options.string import random
from abcli.plugins.markdown import generate_table


def test_generate_table():
    assert generate_table(
        [random() for _ in range(50)],
        cols=4,
    )
