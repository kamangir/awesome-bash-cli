#! /usr/bin/env bash

function abcli_git_browse() {
    local repo_name=$1
    if [[ "$repo_name" == help ]]; then
        options="actions"
        abcli_show_usage "@git browse $EOP.|-|<repo-name>$ABCUL$options$EOPE" \
            "browse <repo-name>."
        return
    fi

    local options=$2
    local browse_actions=$(abcli_option_int "$options" actions 0)

    if [[ ",,.,-," == *",$repo_name,"* ]]; then
        repo_name=$(abcli_git_get_repo_name)
    else
        repo_name=$(abcli_unpack_repo_name $repo_name)
    fi

    local url=https://github.com/kamangir/$repo_name
    [[ "$browse_actions" == 1 ]] && url="$url/actions"

    abcli_browse $url
}
