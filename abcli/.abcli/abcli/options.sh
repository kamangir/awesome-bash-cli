#! /usr/bin/env bash

function abcli_option() {
    python3 -m abcli.options \
        get \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        "${@:4}"
}

function abcli_option_choice() {
    python3 -m abcli.options \
        choice \
        --options "$1" \
        --choices "$2" \
        --default "$3" \
        "${@:4}"
}

function abcli_option_int() {
    python3 -m abcli.options \
        get \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        --is_int 1 \
        "${@:4}"
}

function abcli_option_subset() {
    python3 -m abcli.options \
        subset \
        --options "$1" \
        --subset "$2" \
        "${@:3}"
}
