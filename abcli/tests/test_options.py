import pytest
from abcli.options import Options

test_option_1 = "a,~b,c=1,d=0,var_e,-f,g=2,h=that,i=12.34"


def test_options_add():
    assert True


@pytest.mark.parametrize(
    ["options"],
    [
        [test_option_1],
    ],
)
@pytest.mark.parametrize(
    ["keyword", "default", "expected_value"],
    [
        ["a", "", True],
        ["a", "default", True],
        ["a", False, True],
        ["a", 2, 1],
        ["a", 2.0, 1.0],
        #
        ["b", "", False],
        ["b", "default", False],
        ["b", False, False],
        ["b", 2, 0],
        ["b", 2.0, 0.0],
        #
        ["c", "", "1"],
        ["c", "default", "1"],
        ["c", False, True],
        ["c", 2, 1],
        ["c", 2.0, 1.0],
        #
        ["d", "", "0"],
        ["d", "default", "0"],
        ["d", False, True],
        ["d", 2, 0],
        ["d", 2.0, 0.0],
        #
        ["var_e", "", True],
        ["var_e", "default", True],
        ["var_e", False, True],
        ["var_e", 2, 1],
        ["var_e", 2.0, 1.0],
        #
        ["f", "", False],
        ["f", "default", False],
        ["f", False, False],
        ["f", 2, 0],
        ["f", 2.0, 0.0],
        #
        ["g", "", "2"],
        ["g", "default", "2"],
        ["g", False, True],
        ["g", 2, 2],
        ["g", 2.0, 2.0],
        #
        ["h", "", "that"],
        ["h", "default", "that"],
        ["h", False, True],
        ["h", 2, 2],
        ["h", 2.0, 2.0],
        #
        ["i", "", "12.34"],
        ["i", "default", "12.34"],
        ["i", False, True],
        ["i", 2, 2],
        ["i", 2.0, 12.34],
        #
        ["other", "", ""],
        ["other", "default", "default"],
        ["other", False, False],
        ["other", 2, 2],
        ["other", 2.0, 2.0],
    ],
)
def test_options_get(
    options: str,
    keyword: str,
    default: str,
    expected_value: str,
):
    assert Options(options).get(keyword, default) == expected_value


def test_options_to_str():
    assert True
