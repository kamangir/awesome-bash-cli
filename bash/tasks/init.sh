#! /usr/bin/env bash

function abcli_init() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name init [plugin_1]" \
            "init [plugin_1]."
        return
    fi

    local plugin_name=$task

    local current_path=$(pwd)

    if [ -z "$plugin_name" ] ; then
        source $abcli_path_abcli/bash/abcli.sh
    else
        local repo_name=$(echo "$plugin_name" | tr _ -)

        for filename in $abcli_path_git/$repo_name/abcli/*.sh ; do
            source $filename
        done
    fi

    if [[ "$current_path" == "$abcli_path_git"* ]] ; then
        cd $current_path
    fi
}