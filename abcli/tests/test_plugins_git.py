from blue_objects import file, path

from abcli.plugins.git import version


def test_git_increment_version():
    assert version.increment(
        path.absolute(
            "../../",
            file.path(__file__),
        )
    )
