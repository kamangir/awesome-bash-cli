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

    local repo_name=$(echo "$repo_name" | tr _ -)

    if [ "$repo_name" == "." ]; then
        local current_path=$(pwd)

        if [[ "$current_path" == "$abcli_path_git"* ]]; then
            local repo_name=${current_path#*git}
            local repo_name=$(python3 -c "print('$repo_name/'.split('/')[1])")

            if [ -z "$repo_name" ]; then
                local repo_name="unknown"
            fi
        else
            local repo_name="unknown"
        fi
    fi

    echo $repo_name
}
