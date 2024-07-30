#! /usr/bin/env bash

function abcli_git_checkout() {
    local thing=$1

    if [[ -z "$thing" ]]; then
        abcli_log_error "-@git: checkout: args not found."
        return 1
    fi

    if [[ "$thing" == "help" ]]; then
        options="rebuild"
        abcli_show_usage "@git checkout$ABCUL<branch-name>|<path/filename>$ABCUL[$options]$ABCUL[<args>]" \
            "git checkout <args>."
        return
    fi

    local options=$2
    local do_pull=$(abcli_option_int "$options" pull 1)
    local do_rebuild=$(abcli_option_int "$options" rebuild 0)

    git checkout \
        "$thing" \
        "${@:3}"

    [[ "$do_pull" == 1 ]] &&
        git pull

    [[ "$do_rebuild" == 1 ]] &&
        abcli_git_push "rebuild"
}
