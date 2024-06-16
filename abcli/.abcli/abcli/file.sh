#! /usr/bin/env bash

function abcli_file() {
    python3 -m abcli.file \
        "$1" \
        --filename "$2" \
        "${@:3}"
}
