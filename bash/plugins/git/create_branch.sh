#! /usr/bin/env bash

function abcli_git_create_branch() {
    local branch_name=${1:-$(abcli_string_timestamp)}

    local options=$2
    local do_increment_version=$(abcli_option_int "$options" increment_version 1)

    local repo_name=$(abcli_unpack_repo_name .)

    [[ "$do_increment_version" == 1 ]] && abcli_git increment_version

    pushd $abcli_path_git/$repo_name >/dev/null
    git pull
    git checkout -b $branch_name
    git push origin $branch_name
    popd >/dev/null
}
