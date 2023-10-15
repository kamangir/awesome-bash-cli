#! /usr/bin/env bash

function abcli_watch() {
    local command_line="$@"

    if [ "$command_line" == help ]; then
        abcli_show_usage "abcli watch <command-line>" \
            "watch <command-line>"
        return
    fi
    watch "$HOME/git/awesome-bash-cli/bash/abcli.sh silent \"$command_line\""
}
