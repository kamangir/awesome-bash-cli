#! /usr/bin/env bash

function abcli_GPU() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_name GPU validate" \
            "validate GPU."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.GPU --help
        fi
        return
    fi

    if [ $task == "validate" ] ; then
        python3 -m abcli.plugins.GPU \
            validate \
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: GPU: $task: command not found."
}