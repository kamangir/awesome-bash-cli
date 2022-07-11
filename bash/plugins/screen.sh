#! /usr/bin/env bash

function abcli_screen() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name screen [name_1]" \
            "start a screen [and call it name_1].".
        abcli_help_line "$abcli_cli_name screen kill" \
            "kill all screens."
        abcli_help_line "$abcli_cli_name screen list" \
            "list screens."
        abcli_help_line "$abcli_cli_name screen resume [name_1]" \
            "resume screen [named name_1]."
        return
    fi

    if [ "$task" == "kill" ] ; then
        # https://unix.stackexchange.com/a/94528
        killall screen
        return
    fi

    if [ "$task" == "list" ] ; then
        screen -ls
        return
    fi

    if [ "$task" == "resume" ] ; then
        screen -r ${@:2}
        return
    fi

    local screen_name="$1"
    if [ -z "$screen_name" ]; then
        local screen_name="abcli-$abcli_object_name"
    fi

    screen -q -S $screen_name -t $screen_name
}