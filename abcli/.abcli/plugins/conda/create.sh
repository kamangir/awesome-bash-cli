#! /usr/bin/env bash

function abcli_conda_create() {
    local options=$1
    local clone_from=$(abcli_option "$options" clone auto)
    local do_recreate=$(abcli_option_int "$options" recreate 1)
    local environment_name=$(abcli_option "$options" name abcli)
    local repo_name=$(abcli_unpack_repo_name $environment_name)
    repo_name=$(abcli_option "$options" repo $repo_name)
    local do_install_plugin=$(abcli_option_int "$options" install_plugin 1)

    conda init bash

    if [[ "$do_recreate" == 0 ]] && [[ $(abcli_conda exists $environment_name) == 1 ]]; then
        abcli_eval - conda activate $environment_name
        return
    fi

    if [ "$clone_from" == auto ]; then
        clone_from=""
        [[ "$abcli_is_sagemaker" == true ]] && clone_from=base
    fi

    conda activate base
    conda remove -y --name $environment_name --all

    if [[ -z "$clone_from" ]]; then
        echo "conda: creating $environment_name"
        conda create -y --name $environment_name python=3.9
    else
        echo "conda: cloning $clone_from -> $environment_name"
        conda create -y --name $environment_name --clone $clone_from
    fi

    conda activate $environment_name

    pushd $abcli_path_git/awesome-bash-cli >/dev/null
    pip3 install -e .
    pip3 install -r requirements.txt
    popd >/dev/null

    if [[ "$install_plugin" == 1 ]]; then
        abcli_plugins install $repo_name

        pip3 uninstall -y abcli
        pushd $abcli_path_git/awesome-bash-cli >/dev/null
        pip3 install -e .
        popd >/dev/null
    fi
}
