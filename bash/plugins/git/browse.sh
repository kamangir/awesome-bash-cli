#! /usr/bin/env bash

function abcli_git_browse() {
    local options=$1
    local browse_actions=$(abcli_option_int "$options" actions 0)

    local repo_name=$(abcli_git_get_repo_name)

    local url=https://github.com/kamangir/$repo_name
    [[ "$browse_actions" == 1 ]] && url="$url/actions"

    abcli_browse $url
}
