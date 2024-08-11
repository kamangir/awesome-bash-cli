#! /usr/bin/env bash

function abcli_git_create_branch() {
    local branch_name=$1

    local options=$2

    if [[ "$branch_name" == "help" ]]; then
        options="$EOP~increment_version,~push,~timestamp$EOPE"
        abcli_show_usage "@git create_branch <branch-name>$ABCUL[$options]" \
            "create <branch-name> in the repo."
        return
    fi

    if [[ -z "$branch_name" ]]; then
        abcli_log_error "-@git: create_brach: branch name not found."
        return 1
    fi

    local do_push=$(abcli_option_int "$options" push 1)
    local do_increment_version=$(abcli_option_int "$options" increment_version $(abcli_not $do_push))
    local do_timestamp=$(abcli_option_int "$options" timestamp 1)

    [[ "$do_increment_version" == 1 ]] &&
        abcli_git_increment_version

    [[ "$do_timestamp" == 1 ]] &&
        branch_name=$branch_name-$(abcli_string_timestamp_short)

    git pull
    git checkout -b $branch_name
    git push origin $branch_name

    [[ "$do_push" == 1 ]] &&
        abcli_git_push "start of $branch_name 🪄" first

    return 0
}
