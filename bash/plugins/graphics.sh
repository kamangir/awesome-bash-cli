#! /usr/bin/env bash

function abcli_graphics() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage prefix abcli_graphics_ $@
        return
    fi

    local function_name="abcli_graphics_$task"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name ${@:2}
        return
    fi

    abcli_log_error "-abcli: graphics: $task: command not found."
    return 1
}
