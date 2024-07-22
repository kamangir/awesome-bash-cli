from abcli.string import random_
from abcli.plugins.markdown import generate_table


def test_generate_table():
    assert generate_table(
        [random_() for _ in range(50)],
        cols=4,
    )
