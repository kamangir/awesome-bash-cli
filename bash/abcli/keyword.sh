#! /usr/bin/env bash

function abcli_keyword_is() {
    if [ $(abcli_unpack_keyword "$1") == "$2" ] ; then
        echo true
    else
        echo false
    fi
}

function abcli_pack_keyword() {
    python3 -m abcli.keywords \
        pack \
        --keyword "$1" \
        --default "$2" \
        ${@:3}
}

function abcli_unpack_keyword() {
    python3 -m abcli.keywords \
        unpack \
        --keyword "$1" \
        --default "$2" \
        ${@:3}
}

function abcli_unpack_repo_name() {
    local repo_name=$(abcli_unpack_keyword "$1" awesome-bash-cli)

    local repo_name=$(echo "$repo_name" | tr _ -)

    if [ "$repo_name" == "-" ] || [ "$repo_name" == "." ] ; then
        local repo_name="awesome-bash-cli"
    fi

    echo $repo_name
}