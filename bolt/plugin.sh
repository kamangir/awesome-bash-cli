#! /usr/bin/env bash

function ap() {
    awesome_plugin $@
}

function awesome_plugin() {
    local task=$(bolt_unpack_keyword $1 help)

    if [ $task == "help" ] ; then
        bolt_help_line "awesome_plugin terraform" \
            "terraform awesome_plugin."
        bolt_help_line "awesome_plugin validate" \
            "validate awesome_plugin."

        if [ "$(bolt_keyword_is $2 verbose)" == true ] ; then
            python3 -m awesome_bolt_plugin --help
        fi

        return
    fi

    if [ "$task" == "terraform" ] ; then
        bolt_git terraform awesome-plugin
        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m awesome_bolt_plugin validate
        return
    fi

    bolt_log_error "unknown task: awesome_plugin '$task'."
}