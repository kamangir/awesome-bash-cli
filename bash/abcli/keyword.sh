#! /usr/bin/env bash

function abcli_keyword_is() {
    local unpacked_keyword=$(abcli_unpack_keyword "$1")
    local value=$2

    if [ "$unpacked_keyword" == "$value" ]; then
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
        "${@:3}"
}

function abcli_unpack_keyword() {
    local keyword=$1

    if [[ "$keyword" == "-"* ]]; then
        echo $keyword
        return
    fi

    python3 -m abcli.keywords \
        unpack \
        --keyword "$keyword" \
        --default "$2" \
        "${@:3}"
}

function abcli_unpack_repo_name() {
    local repo_name=$(abcli_unpack_keyword "$1" awesome-bash-cli)

    repo_name=$(echo "$repo_name" | tr _ -)

    [[ "$repo_name" == "." ]] &&
        repo_name=$(abcli_git_get_repo_name)

    echo $repo_name
}
