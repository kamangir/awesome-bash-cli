import os
from abcli import env, path


def list_of_external(repo_names=False):
    """return list of external plugins.

    Args:
        repo_names (bool, optional): return repo names. Defaults to False.

    Returns:
        list[str]: list of external plugins.
    """

    output = sorted(
        [
            repo_name
            for repo_name in [
                path.name(path_)
                for path_ in path.list_of(env.abcli_path_git)
                if path.exist(os.path.join(path_, ".abcli"))
            ]
            if repo_name != "awesome-bash-cli"
        ]
    )

    if not repo_names:
        output = [repo_name.replace("-", "_") for repo_name in output]

    return output
