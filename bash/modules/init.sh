#! /usr/bin/env bash

function abcli_init() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli init [<plugin>] [~terraform]" \
            "init [plugin] [and do not terraform]."
        return
    fi

    local plugin_name=$(abcli_clarify_arg "$1" "all")

    local current_path=$(pwd)

    if [ "$plugin_name" == "all" ] ; then
        source $abcli_path_abcli/bash/abcli.sh ${@:2}
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