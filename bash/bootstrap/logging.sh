#! /usr/bin/env bash

export BLUE='\033[1;34m'
export LIGHTBLUE='\033[1;96m'
export CYAN='\033[0;36m'
export GREEN='\033[0;32m'
export NC='\033[0m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'

function abc_help_line() {
    printf "${LIGHTBLUE}$1${NC}\n"
    if [ ! -z "$2" ] ; then
        printf "${CYAN} . $2${NC}\n"
    fi
}

function abc_log() {
    local message="$@"

    if [ "$message" == "help" ] ; then
        abc_help_line "log \"sth happened\"" \
            "log sth happened."
        abc_help_line "log verbose" \
            "verbose logging on."
        abc_help_line "log verbose off" \
            "verbose logging off."
        return
    fi

    if [ "$message" == "verbose" ] ; then
        touch $abc_path_git/verbose
        abc_set_log_verbosity
        return
    fi

    if [ "$message" == "verbose off" ] ; then
        rm $abc_path_git/verbose
        abc_set_log_verbosity
        return
    fi

    abc_log_local $@

    abc_log_remote $@
}

function abc_log_error() {
    local message="$@"

    printf "${RED}error: $message$NC\n"

    echo "error: $message" >> $abc_log_filename
}

function abc_log_list() {
    local items="$1"
    local delim="$2"
    local postfix="$3"
    local prefix="$4"

    local items=$(abc_list_sort "$items" $delim)

    local count=$(abc_list_len "$items" $delim)
    echo "len($items,$delim):$count"
    printf "$prefix$count $postfix: $GREEN$items$NC\n"
}

function abc_log_local() {
    message="$@"
    printf "${CYAN}${message}${NC}\n"
}

function abc_log_remote() {
    echo "$@" >> $abc_log_filename
}

function abc_set_log_verbosity() {
    if [[ -f $abc_path_git/verbose ]] ; then
        set -x
    else
        set +x
    fi
}