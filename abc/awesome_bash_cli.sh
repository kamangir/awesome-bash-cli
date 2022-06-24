#! /usr/bin/env bash

function abc() {
    awesome_bash_cli $@
}

function awesome_bash_cli() {
    local task=$(abc_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        abc_help_line "awesome_bash_cli terraform" \
            "terraform awesome_bash_cli."
        abc_help_line "awesome_bash_cli validate" \
            "validate awesome_bash_cli."

        if [ "$(abc_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bash_cli --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        abc_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m awesome_bash_cli validate
        return
    fi

    abc_log_error "unknown task: awesome_bash_cli '$task'."
}