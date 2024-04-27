#! /usr/bin/env bash

function abcli_string_after() {
    python3 -m abcli.string \
        after \
        --string "$1" \
        --substring "$2" \
        "${@:3}"
}

function abcli_string_before() {
    python3 -m abcli.string \
        after \
        --string "$1" \
        --substring "$2" \
        "${@:3}"
}

function abcli_string_random() {
    python3 -m abcli.string \
        random \
        "$@"
}

function abcli_string_timestamp() {
    python3 -m abcli.string \
        pretty_date \
        --unique 1 \
        "$@"
}

function abcli_string_timestamp_short() {
    python3 -m abcli.string \
        pretty_date \
        --include_time 0 \
        --unique 1 \
        "$@"
}

function abcli_string_today() {
    python3 -m abcli.string \
        pretty_date \
        --include_time 0 \
        "$@"
}
