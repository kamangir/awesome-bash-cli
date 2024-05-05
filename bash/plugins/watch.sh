#! /usr/bin/env bash

function abcli_watch() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="dryrun,seconds=<seconds>"
        abcli_show_usage "@watch [$options]$ABCUL<command-line>" \
            "watch <command-line>"
        return
    fi

    local command_line="${@:2}"

    abcli_log "watching $command_line ..."

    while true; do
        abcli_eval ,$options "$command_line"

        abcli_sleep ,$options
    done
}
