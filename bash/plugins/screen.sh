#! /usr/bin/env bash

function abcli_screen() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name screen <name>" \
            "start a screen [and call it name].".
        abcli_help_line "$abcli_cli_name screen kill" \
            "kill all screens."
        abcli_help_line "$abcli_cli_name screen list" \
            "list screens."
        abcli_help_line "$abcli_cli_name screen resume <name>" \
            "resume screen [named name]."
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
        local screen_name="abcli-$ABCLI_OBJECT_NAME"
    fi

    screen -q -S $screen_name -t $screen_name
}