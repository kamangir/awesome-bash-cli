#! /usr/bin/env bash

function abcli_init() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli init [<plugin-name>] [clear,~terraform]" \
            "init [<plugin-name>]."
        return
    fi

    local plugin_name=$(abcli_clarify_input "$1" all)
    local options=$2

    local current_path=$(pwd)

    if [ "$plugin_name" == "all" ]; then
        [[ "$abcli_is_mac" == true ]] &&
            local options=~terraform,$options

        local repo_name
        for repo_name in $(echo $abcli_plugins_must_have | tr , " "); do
            abcli_git clone $repo_name if_cloned,install
        done

        source $abcli_path_abcli/abcli/.abcli/abcli.sh "$options" "${@:3}"
    elif [ "$plugin_name" == "clear" ]; then
        abcli_init - clear
    else
        local plugin_name=$(abcli_unpack_keyword $1)
        local repo_name=$(abcli_get_repo_name_from_plugin $plugin_name)
        local module_name=$(abcli_get_module_name_from_plugin $plugin_name)

        for filename in $abcli_path_git/$repo_name/$module_name/.abcli/*.sh; do
            source $filename
        done
    fi

    [[ "$current_path" == "$abcli_path_git"* ]] &&
        cd $current_path

    local do_clear=$(abcli_option_int "$options" clear 0)
    [[ "$do_clear" == 1 ]] &&
        clear

    return 0
}
