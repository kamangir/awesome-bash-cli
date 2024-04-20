#! /usr/bin/env bash

function abcli_git_pull() {
    local options=$1
    local do_all=$(abcli_option_int "$options" all 1)
    local do_init=$(abcli_option_int "$options" init 0)

    local repo_name=$(abcli_unpack_repo_name .)

    local abcli_fullname_before=$abcli_fullname

    pushd $abcli_path_abcli >/dev/null
    git pull

    if [ "$do_all" == 1 ]; then
        local repo
        local filename
        for repo in $(abcli_plugins list_of_external --delim space --log 0 --repo_names 1); do
            if [ -d "$abcli_path_git/$repo" ]; then
                abcli_log $repo
                cd ../$repo
                git pull
                git config pull.rebase false
            fi
        done
    fi
    popd >/dev/null

    [[ "$do_init" == 0 ]] && return 0

    abcli_get_abcli_git_branch

    if [ "$abcli_fullname" == "$abcli_fullname_before" ]; then
        abcli_log "no version change: $abcli_fullname"
        return
    fi

    abcli_log "version change: $abcli_fullname_before -> $abcli_fullname"
    abcli_init
}
