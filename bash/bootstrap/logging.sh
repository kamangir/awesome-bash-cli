#! /usr/bin/env bash

export BLUE='\033[1;34m'
export LIGHTBLUE='\033[1;96m'
export CYAN='\033[0;36m'
export GREEN='\033[0;32m'
export NC='\033[0m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'

# new line
export ABCUL=" \\\\\n\t"

# horizontal line
export ABCHR=$(python3 -c "print(''.join(30*[' .. ']))")

# Extra Options
export ABCXOP=$YELLOW
export ABCXOPE=$LIGHTBLUE
export ABCARGS="$ABCUL$ABCXOP[<args>]$ABCXOPE"

function abcli_show_usage() {
    local what=$1

    if [ "$what" == "prefix" ]; then
        local prefix=$2

        local function_name
        # https://stackoverflow.com/a/2627461/17619982
        for function_name in $(compgen -A function $prefix); do
            $function_name "${@:3}"
        done
        return
    fi

    local command=$1
    local description=$2
    local comments=$3

    if [[ ! -z "$abcli_show_usage_destination" ]]; then
        echo "- - $command" >>$abcli_show_usage_destination
        echo "  - $description" >>$abcli_show_usage_destination
        return
    fi

    printf "${LIGHTBLUE}$command${NC}\n"
    [[ ! -z "$description" ]] &&
        printf "${CYAN} . $description${NC}\n"
    [[ ! -z "$comments" ]] &&
        printf "${GREEN} * $comments${NC}\n"
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
    local items="$1"
    local delim="$2"

    local items=$(abcli_list_sort "$items" --delim "$delim")

    local count=$(abcli_list_len "$items" --delim "$delim")

    local postfix="$3"
    local prefix="$4"
    local message="$prefix$GREEN$count$NC $postfix: $GREEN$items$NC"

    local after="$5"
    if [ ! -z "$after" ]; then
        local message="$message - $after"
    fi

    printf "$message\n"
}

function abcli_log_local() {
    message="$@"
    printf "${CYAN}${message}${NC}\n"
}

function abcli_log_local_and_cat() {
    abcli_log_local "$1"
    cat "$1"
}

function abcli_log_ls() {
    local options=$1
    local path=$(abcli_option "$options" path ./)
    local extension=$(abcli_option "$options" extension sh)

    if [[ "$path" != ./ ]]; then
        abcli_log " 📂 $path"
        pushd $path >/dev/null
    fi

    local filename
    for filename in $(ls *.$extension); do
        abcli_log "📜 ${filename%.*}"
    done

    [[ "$path" != ./ ]] &&
        popd >/dev/null
}

function abcli_log_remote() {
    echo "$@" >>$abcli_log_filename
}

function abcli_log_warning() {
    local message="$@"

    printf "${YELLOW}$message$NC\n"

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
