#! /usr/bin/env bash

function abcli_gpu() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_name gpu validate" \
            "validate gpu."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.gpu --help
        fi
        return
    fi

    if [ $task == "validate" ] ; then
        nvidia-smi
        python3 -m abcli.plugins.gpu \
            validate \
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: gpu: $task: command not found."
}