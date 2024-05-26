#! /usr/bin/env bash

# diff.ignore.start

function abcli_file_size() {
    python3 -m abcli.file \
        size \
        --filename "$1" \
        ${@:2}
}

# diff.ignore.end