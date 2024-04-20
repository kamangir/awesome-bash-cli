#! /usr/bin/env bash

function abcli_get_abcli_git_branch() {
    abcli_get_version

    export abcli_git_branch=$(abcli_git_get_branch awesome-bash-cli)

    export abcli_fullname=abcli-$abcli_version.$abcli_git_branch
}

function abcli_git_get_branch() {
    local repo_name=$(abcli_unpack_repo_name $1)

    local options=$2
    local in_object=$(abcli_option_int "$options" object 0)

    if [ "$in_object" == 1 ]; then
        pushd $abcli_object_path/$repo_name >/dev/null
    else
        pushd $abcli_path_git/$repo_name >/dev/null
    fi

    # https://stackoverflow.com/a/1593487
    local branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
        local branch_name="master" # detached HEAD

    popd >/dev/null

    local branch_name=${branch_name##refs/heads/}

    echo $branch_name
}

# internal function for abcli_seed.
function git_seed() {
    # seed is NOT local
    local user_email=$(git config --global user.email)
    seed="${seed}git config --global user.email \"$user_email\"$delim"

    local user_name=$(git config --global user.name)
    seed="${seed}git config --global user.name \"$user_name\"$delim_section"
}
