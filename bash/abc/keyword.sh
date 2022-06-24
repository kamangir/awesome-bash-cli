#! /usr/bin/env bash

function abc_keyword_is() {
    if [ $(abc_unpack_keyword "$1") == "$2" ] ; then
        echo true
    else
        echo false
    fi
}

function abc_pack_keyword() {
    python3 -m abc.keywords \
        pack \
        --keyword "$1" \
        --default "$2" \
        ${@:3}
}

function abc_unpack_keyword() {
    python3 -m abc.keywords \
        unpack \
        --keyword "$1" \
        --default "$2" \
        ${@:3}
}

function abc_unpack_repo_name() {
    local repo_name=$(abc_unpack_keyword "$1" awesome-bash-cli)

    local repo_name=$(echo "$repo_name" | tr _ -)

    if [ "$repo_name" == "-" ] || [ "$repo_name" == "." ] ; then
        local repo_name="awesome-bash-cli"
    fi

    echo $repo_name
}