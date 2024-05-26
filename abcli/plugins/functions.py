from typing import List
import glob
import os
from abcli import env, path, file


def get_plugin_name(repo_name: str) -> str:
    return "abcli" if repo_name == "awesome-bash-cli" else repo_name.replace("-", "_")


def get_module_name(repo_name: str) -> str:
    list_of_candidates = sorted(
        file.path(filename)
        for filename in glob.glob(
            os.path.join(env.abcli_path_git, repo_name, "**/__init__.py"),
            recursive=True,
        )
    )

    if not list_of_candidates:
        return "no-module-found"

    return path.name(list_of_candidates[0])


def list_of_external(repo_names=False) -> List[str]:
    output = sorted(
        [
            repo_name
            for repo_name in [
                path.name(path_)
                for path_ in glob.glob(os.path.join(env.abcli_path_git, "*/"))
            ]
            if repo_name != "awesome-bash-cli"
            and path.exist(
                os.path.join(
                    env.abcli_path_git,
                    repo_name,
                    get_module_name(repo_name),
                    ".abcli",
                )
            )
        ]
    )

    if not repo_names:
        output = [repo_name.replace("-", "_") for repo_name in output]

    return output
