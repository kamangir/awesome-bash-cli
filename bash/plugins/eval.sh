#! /usr/bin/env bash

function abcli_eval() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "abcli eval [dryrun]$ABCUL<command-line>" \
            "eval <command-line>."
        return
    fi

    local dryrun=$(abcli_option_int "$options" dryrun 0)
    local path=$(abcli_option "$options" path ./)

    local command_line="${@:2}"

    abcli_log "⚙️  $command_line"
    [[ "$dryrun" == 1 ]] && return

    abcli_log "🔗 $path"
    pushd $path >/dev/null
    eval "$command_line"
    popd >/dev/null
}
