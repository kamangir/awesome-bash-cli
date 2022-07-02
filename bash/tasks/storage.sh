#! /usr/bin/env bash

function abcli_storage() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "storage clear" \
            "clear storage."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.tasks.storage --help
        fi
        return
    fi

    if [[ "$task" == "clear" ]]; then
        cd    
        rm -rf $abcli_path_storage/*
        abcli_select $abcli_object_name
        return
    fi

    abcli_log_error "-abcli: storage: $task: command not found."
}