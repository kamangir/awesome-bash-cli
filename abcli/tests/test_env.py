import os
from abcli import env
from abcli import file


def test_abcli_env():
    assert file.exist(os.path.join(env.parent_dir, "config.env"))

    assert env.abcli_path_home
    assert env.abcli_path_git
    assert env.abcli_path_storage

    assert env.ABCLI_AWS_RDS_DB
    assert env.ABCLI_AWS_RDS_PORT
    assert env.ABCLI_AWS_RDS_USER
