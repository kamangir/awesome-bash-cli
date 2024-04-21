#! /usr/bin/env bash

function abcli_git_increment_version() {
    local repo_name=$(abcli_unpack_repo_name .)

    local options=$1
    local do_diff=$(abcli_option_int "$options" diff 0)

    python3 -m abcli.plugins.git \
        increment_version \
        --repo_path $abcli_path_git/$repo_name \
        "${@:2}"

    [[ "$do_diff" == 1 ]] && abcli_git diff

    return 0
}
