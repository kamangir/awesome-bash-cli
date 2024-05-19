#! /usr/bin/env bash

function abcli_git_get_repo_name() {
    local repo_name="unknown"

    if [[ "$PWD" == "$abcli_path_git"* ]]; then
        repo_name="${PWD#*$abcli_path_git/}"
        repo_name="${repo_name%%/*}"
        repo_name="${repo_name:-unknown}"
    fi

    echo "$repo_name"
}
