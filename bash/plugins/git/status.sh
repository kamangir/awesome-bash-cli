#! /usr/bin/env bash

function abcli_git_status() {
    local options=$1
    local do_all=$(abcli_option_int "$options" all 1)

    local repo_name=$(abcli_unpack_repo_name .)

    if [[ "$do_all" == 0 ]]; then
        abcli_eval path=$abcli_path_git/$repo_name,~log \
            git status
        return
    fi

    pushd $abcli_path_git >/dev/null
    local repo_name
    for repo_name in $(ls -d */); do
        abcli_log $repo_name

        cd $repo_name
        git status
        cd ..
    done
    popd >/dev/null
}
