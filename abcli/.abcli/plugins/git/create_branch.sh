#! /usr/bin/env bash

function abcli_git_create_branch() {
    local branch_name=$1
    if [[ -z "$branch_name" ]]; then
        abcli_log_error "-@git: create_brach: branch name not found."
        return 1
    fi

    local options=$2
    local do_push=$(abcli_option_int "$options" push 1)
    local do_increment_version=$(abcli_option_int "$options" increment_version $(abcli_not $do_push))

    [[ "$do_increment_version" == 1 ]] &&
        abcli_git increment_version

    git pull
    git checkout -b $branch_name
    git push origin $branch_name

    [[ "$do_push" == 1 ]] &&
        abcli_git_push "fascinating feature 🪄" first

    return 0
}
