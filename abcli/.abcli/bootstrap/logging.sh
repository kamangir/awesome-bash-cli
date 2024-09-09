#! /usr/bin/env bash

function abcli_log() {
    local task=$(abcli_unpack_keyword "$1")

    if [ "$task" == "help" ]; then
        abcli_show_usage "@log <message>" \
            "log message."

        abcli_show_usage "@log verbose [on/off]" \
            "verbose logging on/off."
        return
    fi

    if [ "$task" == "verbose" ]; then
        local what=${2-on}

        if [ "$what" == "on" ]; then
            touch $abcli_path_git/verbose
            abcli_set_log_verbosity
        elif [ "$what" == "off" ]; then
            rm $abcli_path_git/verbose
            abcli_set_log_verbosity
        else
            abcli_log_error "@log: verbose: $what: command not found."
            return 1
        fi

        return
    fi

    abcli_log_local "$@"

    abcli_log_remote "$@"
}

function abcli_log_error() {
    local message="$@"

    printf "❗️ ${RED}$message$NC\n"

    echo "error: $message" >>$abcli_log_filename
}

function abcli_log_remote() {
    echo "$@" >>$abcli_log_filename
}

function abcli_log_warning() {
    local message="$@"

    printf "$YELLOW$message$NC\n"

    echo "warning: $message" >>$abcli_log_filename
}

function abcli_set_log_verbosity() {
    if [[ -f $abcli_path_git/verbose ]]; then
        set -x
    else
        set +x
    fi
}

abcli_set_log_verbosity

if [ -z "$abcli_log_filename" ]; then
    export abcli_log_filename="abcli.log"
fi
