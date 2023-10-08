#! /usr/bin/env bash

function abcli_conda() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli conda create_env$ABCUL[dryrun,~pip,tensorflow,torch]$ABCUL[<environment-name>]" \
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
        local do_pip=$(abcli_option_int "$options" pip 1)
        local install_tensorflow=$(abcli_option_int "$options" tensorflow 0)
        local install_torch=$(abcli_option_int "$options" torch 0)

        local environment_name=$(abcli_clarify_input $3 abcli)

        conda activate base
        conda remove -y --name $environment_name --all

        conda create -y -n $environment_name python=3.9
        conda activate $environment_name

        pushd $abcli_path_git/awesome-bash-cli >/dev/null
        pip3 install -e .
        popd >/dev/null

        local list_of_modules="matplotlib jupyter pandas scikit-learn opencv-python \
            dill tqdm boto3 pymysql==0.10.1 numpy geopandas"
        [[ "$install_tensorflow" == 1 ]] &&
            local list_of_modules="$list_of_modules tensorflow keras"
        [[ "$install_torch" == 1 ]] &&
            local list_of_modules="$list_of_modules torch"

        local module
        for module in $list_of_modules; do
            abcli_eval dryrun=$(abcli_not $do_pip) \
                pip3 install $module
        done

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
