#! /usr/bin/env bash

export BLUE='\033[1;34m'
export LIGHTBLUE='\033[1;96m'
export CYAN='\033[0;36m'
export GREEN='\033[0;32m'
export NC='\033[0m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'

function abcli_help_line() {
    printf "${LIGHTBLUE}$1${NC}\n"
    if [ ! -z "$2" ] ; then
        printf "${CYAN} . $2${NC}\n"
    fi
}

function abcli_log() {
    local task=$(abcli_unpack_keyword "$1")

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name log <message>" \
            "log message."
        abcli_help_line "$abcli_cli_name log verbose [on/off]" \
            "verbose logging on/off."
        return
    fi

    if [ "$task" == "verbose" ] ; then
        local what=${2-on}

        if [ "$what" == "on" ] ; then
            touch $abcli_path_git/verbose
            abcli_set_log_verbosity
        elif [ "$what" == "off" ] ; then
            rm $abcli_path_git/verbose
            abcli_set_log_verbosity
        else
            abcli_log_error "-abcli: log: verbose: $what: command not found."
        fi

        return
    fi

    abcli_log_local $@

    abcli_log_remote $@
}

function abcli_log_error() {
    local message="$@"

    printf "${RED}$message$NC\n"

    echo "error: $message" >> $abcli_log_filename
}

function abcli_log_list() {
    local items="$1"
    local delim="$2"

    local items=$(abcli_list_sort "$items" --delim "$delim")

    local count=$(abcli_list_len "$items" --delim "$delim")

    local postfix="$3"
    local prefix="$4"
    local message="$prefix$GREEN$count$NC $postfix: $GREEN$items$NC"

    local after="$5"
    if [ ! -z "$after" ] ; then
        local message="$message - $after"
    fi

    printf "$message\n"
}

function abcli_log_local() {
    message="$@"
    printf "${CYAN}${message}${NC}\n"
}

function abcli_log_remote() {
    echo "$@" >> $abcli_log_filename
}

function abcli_set_log_verbosity() {
    if [[ -f $abcli_path_git/verbose ]] ; then
        set -x
    else
        set +x
    fi
}

abcli_set_log_verbosity

if [ -z "$abcli_log_filename" ] ; then
    export abcli_log_filename="abcli.log"
fi