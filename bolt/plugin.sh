#! /usr/bin/env bash

function bolt_awesome_plugin() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        bolt_help_line "bolt_awesome_plugin terraform" \
            "terraform bolt_awesome_plugin."
        bolt_help_line "bolt_awesome_plugin validate" \
            "validate bolt_awesome_plugin."

        if [ "$(bolt_keyword_is $2 verbose)" == true ] ; then
            python3 -m bolt_awesome_plugin --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        bolt_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m bolt_awesome_plugin validate
        return
    fi

    bolt_log_error "unknown task: bolt_awesome_plugin '$task'."
}