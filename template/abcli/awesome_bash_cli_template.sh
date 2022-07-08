#! /usr/bin/env bash

function abct() {
    awesome_bash_cli_template $@
}

function awesome_bash_cli_template() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        abcli_help_line "abct task_1" \
            "run abct task_1."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bash_cli_template --help
        fi

        return
    fi

    if [ "$task" == "task_1" ] ; then
        python3 -m awesome_bash_cli_template \
            task_1 \
            ${@:2}
        return
    fi

    abcli_log_error "-awesome_bash_cli_template: $task: command not found."
}