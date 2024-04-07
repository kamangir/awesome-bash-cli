#! /usr/bin/env bash

function abcli_eval() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="dryrun,~log,path=<path>"
        abcli_show_usage "abcli eval$ABCUL[$options]$ABCUL<command-line>" \
            "eval <command-line>."
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_log=$(abcli_option_int "$options" log 1)
    local path=$(abcli_option "$options" path ./)

    [[ "$path" != "./" ]] && mkdir -pv $path

    local command_line="${@:2}"

    if [[ "$do_log" == 1 ]]; then
        abcli_log "⚙️  $command_line"
        [[ "$path" != "./" ]] && abcli_log " 📂 $path"
    fi

    [[ "$do_dryrun" == 1 ]] && return

    [[ "$path" != "./" ]] && pushd $path >/dev/null
    eval "$command_line"
    [[ "$path" != "./" ]] && popd >/dev/null

    return 0
}
