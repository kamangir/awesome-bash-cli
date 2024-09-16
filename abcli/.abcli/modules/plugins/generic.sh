#! /usr/bin/env bash

function abcli_generic_task() {
    local options=$1
    local plugin_name=$(abcli_option "$options" plugin abcli)
    local task=$(abcli_option "$options" task unknown)

    local function_name="${plugin_name}_${task}"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    if [ "$task" == "build_README" ]; then
        abcli_build_README \
            plugin=$plugin_name,$2 \
            "${@:3}"
        return
    fi

    if [ "$task" == "init" ]; then
        abcli_init $plugin_name "${@:2}"

        [[ "$abcli_is_docker" == false ]] &&
            [[ $(abcli_conda exists $plugin_name) == 1 ]] &&
            conda activate $plugin_name

        return 0
    fi

    if [[ "|pylint|pytest|test|" == *"|$task|"* ]]; then
        abcli_${task} plugin=$plugin_name,$2 \
            "${@:3}"
        return
    fi

    if [[ "|pypi|" == *"|$task|"* ]]; then
        abcli_${task} "$2" \
            plugin=$plugin_name,$3 \
            "${@:4}"
        return
    fi

    [[ "$task" == "help" ]] && task="version"

    local module_name=$(abcli_get_module_name_from_plugin $plugin_name)
    python3 -m $module_name "$task" "${@:2}"
}
