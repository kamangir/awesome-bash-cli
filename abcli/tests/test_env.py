from abcli import env


def test_abcli_env():
    assert env.ABCLI_AWS_RDS_DB
    assert env.ABCLI_AWS_RDS_PORT
    assert env.ABCLI_AWS_RDS_USER
