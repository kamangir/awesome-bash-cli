#! /usr/bin/env bash

function abcli_plugins_transform() {
    local plugin_name=$(abcli_unpack_keyword "$1")

    if [[ "$plugin_name" == help ]]; then
        abcli_show_usage "@plugins transform$ABCUL<repo-name>" \
            "transform a blue-plugin git clone to <repo-name>."
        return
    fi

    local repo_name=$1
    if [[ -z "$repo_name" ]]; then
        abcli_log_error "-@plugins: transform: $repo_name: repo not found."
        return 1
    fi
    local plugin_name=$(abcli_plugin_name_from_repo $repo_name)

    abcli_log "blue-plugin -> $repo_name ($plugin_name)"

    pushd $abcli_path_git/$repo_name >/dev/null

    git mv blue_plugin $plugin_name

    git mv \
        $plugin_name/.abcli/blue_plugin.sh \
        $plugin_name/.abcli/$plugin_name.sh

    rm -v $plugin_name/.abcli/session.sh

    local filename
    for filename in $(find . -type f \( -name "*.sh" \
        -o -name "*.py" \
        -o -name "*.yml" \)); do

        abcli_file replace \
            $filename \
            --this blue_plugin \
            --that $plugin_name

        abcli_file replace \
            $filename \
            --this blue-plugin \
            --that $repo_name

    done

    echo "# $plugin_name" >README.md

    popd >/dev/null

}
