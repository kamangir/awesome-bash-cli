#! /usr/bin/env bash

function abcli_git_increment_version() {
    local repo_name=$(abcli_unpack_repo_name .)

    python3 -m abcli.plugins.git \
        increment_version \
        --repo_path $abcli_path_git/$repo_name \
        "${@:2}"
}
