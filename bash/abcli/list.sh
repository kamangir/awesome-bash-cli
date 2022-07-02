#! /usr/bin/env bash

function abcli_list_in() {
    python3 -m abcli.bash.list \
        in \
        --item "$1" \
        --items "$2" \
        --delim "$3" \
        ${@:4}
}

function abcli_list_len() {
    python3 -m abcli.bash.list \
        len \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}

function abcli_list_nonempty() {
    python3 -m abcli.bash.list \
        nonempty \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}

function abcli_list_resize() {
    python3 -m abcli.bash.list \
        resize \
        --items "$1" \
        --delim "$2" \
        --count $3 \
        ${@:4}
}

function abcli_list_sort() {
    python3 -m abcli.bash.list \
        sort \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}