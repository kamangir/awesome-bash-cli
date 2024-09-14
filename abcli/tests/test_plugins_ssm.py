import time
import pytest
from abcli.plugins.ssm.functions import get_secret, put_secret, rm_secret
from blue_options.string import random


def test_ssm():
    secret_name = "pytest-{}".format(random())
    secret_value = random()

    success, _ = put_secret(secret_name, secret_value)
    assert success

    time.sleep(1)

    success, secret_value_received = get_secret(secret_name)
    assert success, secret_value_received
    assert not secret_value_received or (
        secret_value_received == secret_value
    ), f"{secret_value_received} != {secret_value}"

    success = rm_secret(secret_name)
    assert success
