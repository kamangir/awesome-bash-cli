#! /usr/bin/env bash

function abcli_screen() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli screen <name>" \
            "start a screen [and call it name].".
        abcli_show_usage "abcli screen kill" \
            "kill all screens."
        abcli_show_usage "abcli screen list" \
            "list screens."
        abcli_show_usage "abcli screen resume <name>" \
            "resume screen [named name]."
        return
    fi

    if [ "$task" == "kill" ]; then
        abcli_killall screen
        return
    fi

    if [ "$task" == "list" ]; then
        screen -ls
        return
    fi

    if [ "$task" == "resume" ]; then
        screen -r ${@:2}
        return
    fi

    local screen_name="$1"
    if [ -z "$screen_name" ]; then
        local screen_name="abcli-$abcli_object_name"
    fi

    screen -q -S $screen_name -t $screen_name
}
