#! /usr/bin/env bash

function abcli_conda() {
    local task=$(abcli_unpack_keyword $1 help)
    
    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name conda create_env" \
            "create conda environmnt."
        return
    fi

    if [ "$task" == "create_env" ] ; then
        conda activate base
        conda remove -y --name abcli --all

        conda create -y -n abcli python=3.9
        conda activate abcli

        conda install -y -c conda-forge tensorflow
        conda install -y -c conda-forge keras
        conda install -y -c conda-forge matplotlib
        conda install -y -c conda-forge jupyter
        conda install -y pandas
        conda install -y -c conda-forge scikit-learn
        conda install -y -c conda-forge opencv
        conda install -y -c conda-forge dill

        pip3 install boto3
        pip3 install pymysql==0.10.1

        # https://stackoverflow.com/a/65993776/17619982
        conda install -y numpy==1.19.5

        pushd $abcli_path_git/awesome-bash-cli > /dev/null
        pip3 install -e .
        popd > /dev/null

        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m abcli2.bootstrap \
            validate
        lspci # -v
        nvidia-smi
        return
    fi

    abcli_log_error "-abcli: conda: $task: command not found."
}