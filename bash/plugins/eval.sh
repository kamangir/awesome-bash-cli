#! /usr/bin/env bash

function abcli_eval() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "abcli eval$ABCUL[dryrun]$ABCUL<command-line>" \
            "eval <command-line>."
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_log=$(abcli_option_int "$options" log 1)
    local path=$(abcli_option "$options" path ./)

    local command_line="${@:2}"

    [[ "$do_log" == 1 ]] && abcli_log "⚙️  $command_line"
    [[ "$do_dryrun" == 1 ]] && return

    [[ "$do_log" == 1 ]] && [[ "$path" != "./" ]] && abcli_log "📂 $path"

    pushd $path >/dev/null
    eval "$command_line"
    popd >/dev/null
}
