#! /usr/bin/env bash

function abcli_conda() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli conda create_env$ABCUL[clone=<auto|base>,name=<environment-name>]" \
            "create conda environmnt."
        abcli_show_usage "abcli conda list" \
            "show list of conda environments."
        abcli_show_usage "abcli conda remove|rm$ABCUL[<environment-name>]" \
            "remove environment."
        return
    fi

    if [[ ",remove,rm," == *",$task,"* ]]; then
        local environment_name=$(abcli_clarify_input $2 abcli)

        conda activate base
        conda remove -y --name $environment_name --all

        return
    fi

    if [ "$task" == "create_env" ]; then
        local options=$2
        local clone_from=$(abcli_option "$options" clone auto)
        local environment_name=$(abcli_option "$options" name abcli)

        if [ "$clone_from" == auto ]; then
            if [[ "$abcli_is_sagemaker" == true ]]; then
                local clone_from=base
            else
                local clone_from=""
            fi
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
        popd >/dev/null

        abcli_eval \
            path=$abcli_path_git/$environment_name \
            pip3 install -e .

        return
    fi

    if [ "$task" == "list" ]; then
        abcli_eval - \
            conda info --envs
        return
    fi

    if [ "$task" == "validate" ]; then
        python3 -m abcli2.bootstrap \
            validate
        lspci # -v
        nvidia-smi
        return
    fi

    abcli_log_error "-abcli: conda: $task: command not found."
}
