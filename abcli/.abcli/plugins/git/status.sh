#! /usr/bin/env bash

function abcli_git_status() {
    local options=$1
    local do_all=$(abcli_option_int "$options" all 1)

    if [[ "$do_all" == 0 ]]; then
        abcli_eval path=$abcli_path_git/$(abcli_git_get_repo_name),~log \
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
