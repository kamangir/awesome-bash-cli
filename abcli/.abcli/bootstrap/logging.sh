#! /usr/bin/env bash

function abcli_hr() {
    local width=80
    [[ "$abcli_is_github_workflow" == false ]] &&
        [[ "$abcli_is_aws_batch" == false ]] &&
        width=$(tput cols)

    printf "$(python3 -m abcli.bash.logging hr \
        --width $width)\n"
}

function abcli_log() {
    local task=$(abcli_unpack_keyword "$1")

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli log <message>" \
            "log message."
        abcli_show_usage "abcli log verbose [on/off]" \
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
            abcli_log_error "-abcli: log: verbose: $what: command not found."
            return 1
        fi

        return
    fi

    abcli_log_local "$@"

    abcli_log_remote "$@"
}

function abcli_log_error() {
    local message="$@"

    printf "${RED}$message$NC\n"

    echo "error: $message" >>$abcli_log_filename
}

function abcli_log_file() {
    local filename=${1:-help}

    if [ "$filename" == "help" ]; then
        abcli_show_usage "abcli log_file <filename>" \
            "log <filename>."
        return
    fi

    if [ ! -f "$filename" ]; then
        abcli_log_error "-abcli: log: file: $filename: file not found."
        return 1
    fi

    printf "🗒️  $YELLOW$filename$NC\n$BLUE"
    cat $filename
    printf "$NC\n🗒️  $YELLOW/$filename$NC\n"
}

function abcli_log_list() {
    local items=$1

    if [[ "$items" == "help" ]]; then
        local args="[--before \"list of\"]$ABCUL[--after \"items(s)\"]$ABCUL[--delim space|<delim>]"
        abcli_show_usage "abcli_log_list <this,that>$ABCUL$EOP$args$EOPE" \
            "log list."
        return
    fi

    local message=$(python3 -m abcli.bash.list \
        log \
        --items "$items" \
        "${@:2}")
    printf "$message\n"
}

function abcli_log_local_and_cat() {
    abcli_log_local "$1"
    cat "$1"
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
