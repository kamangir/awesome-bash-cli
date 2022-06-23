#! /usr/bin/env bash

function abc() {
    awesome_bash_cli $@
}

function awesome_bash_cli() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        bolt_help_line "awesome_bash_cli terraform" \
            "terraform awesome_bash_cli."
        bolt_help_line "awesome_bash_cli validate" \
            "validate awesome_bash_cli."

        if [ "$(bolt_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bash_cli --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        bolt_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m awesome_bash_cli validate
        return
    fi

    bolt_log_error "unknown task: awesome_bash_cli '$task'."
}