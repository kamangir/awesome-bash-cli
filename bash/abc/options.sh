#! /usr/bin/env bash

function abc_option() {
    python3 -m abc.options \
        get \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        ${@:4}
}

function abc_option_default() {
    python3 -m abc.options \
        default \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        ${@:4}
}

function abc_option_int() {
    python3 -m abc.options \
        get \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        --is_int 1 \
        ${@:4}
}

function abc_option_get_unpacked() {
    python3 -m abc.options \
        get_unpacked \
        --options "$1" \
        --keyword "$2" \
        --default "$3" \
        --is_int 1 \
        ${@:4}
}