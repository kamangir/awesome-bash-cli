#! /usr/bin/env bash

function abc_list_in() {
    python3 -m abc.bash.list \
        in \
        --item "$1" \
        --items "$2" \
        --delim "$3" \
        ${@:4}
}

function abc_list_len() {
    python3 -m abc.bash.list \
        len \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}

function abc_list_nonempty() {
    python3 -m abc.bash.list \
        non_empty \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}

function abc_list_resize() {
    python3 -m abc.bash.list \
        resize \
        --items "$1" \
        --delim "$2" \
        --count $3 \
        ${@:4}
}

function abc_list_sort() {
    python3 -m abc.bash.list \
        sort \
        --items "$1" \
        --delim "$2" \
        ${@:3}
}