#! /usr/bin/env bash

function abcli_huggingface() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name git clone repo_1" \
            "clone huggingface/repo_1."
        abcli_help_line "$abcli_cli_name huggingface install" \
            "install huggingface."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.huggingface --help
        fi
        return
    fi

    if [ $task == "clone" ] ; then
        pushd $abcli_path_git > /dev/null
        git clone https://huggingface.co/kamangir/$2
        popd > /dev/null
        return
    fi

    if [ $task == "install" ] ; then
        python3 -m pip install huggingface_hub
        huggingface-cli login
        return
    fi

    abcli_log_error "-abcli: huggingface: $task: command not found."
}