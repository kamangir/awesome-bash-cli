#! /usr/bin/env bash

function abcli_init() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli init [<plugin>] [~terraform]" \
            "init [plugin] [and do not terraform]."
        return
    fi

    local plugin_name=$(abcli_clarify_input "$1" all)

    local current_path=$(pwd)

    if [ "$plugin_name" == "all" ] ; then
        local options=$2
        if [ "$abcli_is_mac" == true ] ; then
            local options=$(abcli_option_default "$options" terraform 0)
        fi

        local repo_name
        for repo_name in $(echo $(abcli_cookie read plugins) | tr , " ") ; do
            abcli_git clone $repo_name if_cloned,install
        done

        source $abcli_path_abcli/bash/abcli.sh "$options" ${@:3}
    else
        local plugin_name=$(abcli_unpack_keyword $1)
        local repo_name=$(echo "$plugin_name" | tr _ -)

        for filename in $abcli_path_git/$repo_name/.abcli/*.sh ; do
            source $filename
        done
    fi

    if [[ "$current_path" == "$abcli_path_git"* ]] ; then
        cd $current_path
    fi
}