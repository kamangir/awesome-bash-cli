#! /usr/bin/env bash

function abct() {
    awesome_bash_cli_template $@
}

function awesome_bash_cli_template() {
    local task=$(abc_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        abc_help_line "awesome_bash_cli_template terraform" \
            "terraform awesome_bash_cli_template."
        abc_help_line "awesome_bash_cli_template validate" \
            "validate awesome_bash_cli_template."

        if [ "$(abc_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bash_cli_template --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        abc_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m awesome_bash_cli_template validate
        return
    fi

    abc_log_error "unknown task: awesome_bash_cli_template '$task'."
}