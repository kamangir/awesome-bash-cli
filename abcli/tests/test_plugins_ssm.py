import pytest
from abcli.plugins.ssm.functions import get_secret, put_secret
from abcli.string import random_


@pytest.mark.parametrize(
    [
        "secret_name",
    ],
    [["pytest_secret"]],
)
def test_ssm(secret_name: str):
    value = random_()

    success, _ = put_secret(secret_name, value)
    assert success

    success, secret_value = get_secret(secret_name)
    assert success
    assert secret_value == value
