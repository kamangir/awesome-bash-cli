import pytest
from abcli import env
from abcli.plugins.functions import list_of_external, get_plugin_name, get_module_name


@pytest.mark.skipif(
    env.abcli_is_github_workflow == "true",
    reason="plugins are not present in the github workflow.",
)
def test_list_of_external():
    assert list_of_external()


@pytest.mark.skipif(
    env.abcli_is_github_workflow == "true",
    reason="plugins are not present in the github workflow.",
)
@pytest.mark.parametrize(
    [
        "repo_name",
        "plugin_name",
        "module_name",
    ],
    [
        [
            "awesome-bash-cli",
            "abcli",
            "abcli",
        ],
        [
            "CV",
            "CV",
            "abadpour",
        ],
        [
            "roofAI",
            "roofAI",
            "roofAI",
        ],
        [
            "vancouver-watching",
            "vancouver_watching",
            "vancouver_watching",
        ],
        [
            "giza",
            "giza",
            "gizai",
        ],
        [
            "hubble",
            "hubble",
            "hubblescope",
        ],
        [
            "aiart",
            "aiart",
            "articraft",
        ],
    ],
)
def test_get(
    repo_name: str,
    plugin_name: str,
    module_name: str,
):
    assert get_plugin_name(repo_name) == plugin_name
    assert get_module_name(repo_name) == module_name
