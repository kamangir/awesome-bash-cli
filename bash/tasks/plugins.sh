#! /usr/bin/env bash

function abcli_external_plugins() {
    python3 -m abcli.plugins \
            list_of_external \
            --delim "$1" \
            ${@:2}
}
