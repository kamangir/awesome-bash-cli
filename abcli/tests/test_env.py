from abcli import env


def test_abcli_env():
    assert env.abcli_path_home
    assert env.abcli_path_git
    assert env.storage
