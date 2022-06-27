#! /usr/bin/env bash

function abct() {
    awesome_bash_cli_template $@
}

function awesome_bash_cli_template() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        abcli_help_line "awesome_bash_cli_template terraform" \
            "terraform awesome_bash_cli_template."
        abcli_help_line "awesome_bash_cli_template validate" \
            "validate awesome_bash_cli_template."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bash_cli_template --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        abcli_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m awesome_bash_cli_template validate
        return
    fi

    abcli_log_error "-awesome_bash_cli_template: $task: command not found."
}