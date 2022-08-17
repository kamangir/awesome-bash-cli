#! /usr/bin/env bash

function abcli_hardware() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "hardware input" \
            "read hardware inputs."
        abcli_help_line "hardware output <10101010>" \
            "activate hardware outputs to 10101010."
        abcli_help_line "hardware validate" \
            "validate hardware."


        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.modules.hardware --help
        fi
        return
    fi

    if [ "$task" == "input" ] ; then
        python3 -m abcli.modules.hardware \
            input \
            ${@:2}
        return
    fi

    if [ "$task" == "output" ] ; then
        python3 -m abcli.modules.hardware \
            output \
            --outputs "$2" \
            ${@:3}
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m abcli.modules.hardware \
            validate \
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: hardware: $task: command not found."
}
