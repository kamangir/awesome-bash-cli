#! /usr/bin/env bash

function abcli_huggingface() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name huggingface install" \
            "install huggingface."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.huggingface --help
        fi
        return
    fi

    if [ $task == "install" ] ; then
        python3 -m pip install huggingface_hub
        return
    fi

    abcli_log_error "-abcli: huggingface: $task: command not found."
}