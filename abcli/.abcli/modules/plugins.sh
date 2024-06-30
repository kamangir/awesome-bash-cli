#! /usr/bin/env bash

function abcli_plugins() {
    local task=$(abcli_unpack_keyword "$1")

    if [ "$task" == "help" ]; then
        abcli_plugins_install "$@"

        abcli_show_usage "@plugins get_module_name$ABCUL<repo-name>" \
            "get module name."

        abcli_show_usage "@plugins list_of_external" \
            "show list of external plugins."

        abcli_show_usage "@plugins list_of_installed" \
            "show list of installed plugins."

        abcli_plugins_transform "$@"

        return 0
    fi

    local function_name="abcli_plugins_$1"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    if [ $task == "get_module_name" ]; then
        python3 -m abcli.plugins \
            get_module_name \
            --repo_name "$2" \
            "${@:3}"
        return
    fi

    if [ $task == "list_of_external" ]; then
        python3 -m abcli.plugins \
            list_of_external \
            "${@:2}"
        return
    fi

    python3 -m abcli.plugins "$task" "${@:2}"
}

abcli_source_path - caller,suffix=/plugins
