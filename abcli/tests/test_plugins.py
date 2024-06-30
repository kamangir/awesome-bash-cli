import pytest
from abcli import env
from abcli.plugins.functions import (
    list_of_external,
    list_of_installed,
    get_plugin_name,
    get_module_name,
)


@pytest.mark.parametrize(
    ["repo_names"],
    [
        [True],
        [False],
    ],
)
def test_list_of_external(repo_names: bool):
    assert isinstance(list_of_external(repo_names), list)


@pytest.mark.parametrize(
    ["return_path"],
    [
        [True],
        [False],
    ],
)
def test_list_of_installed(return_path: bool):
    assert isinstance(list_of_installed(return_path), list)


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
