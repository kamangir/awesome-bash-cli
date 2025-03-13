#! /usr/bin/env bash

function abcli_plugins_install() {
    local plugin_name=$(abcli_unpack_keyword $1 all)

    if [[ "$plugin_name" == all ]]; then
        pushd $abcli_path_git >/dev/null
        for dir in */; do
            if ! find "$dir" -type d -name ".abcli" -print -quit | read; then
                continue
            fi

            abcli_log "$dir ..."

            cd $dir
            pip3 install -e .
            pip3 install -r requirements.txt
            cd ..
        done
        popd >/dev/null
        return
    fi

    local repo_name=$(abcli_get_repo_name_from_plugin $plugin_name)
    if [[ -z "$repo_name" ]]; then
        abcli_log_error "@plugins: install: $plugin_name: plugin not found."
        return 1
    fi

    abcli_log "installing $plugin_name from $repo_name"

    pushd $abcli_path_git/$repo_name >/dev/null
    pip3 install -e .
    pip3 install -r requirements.txt
    popd >/dev/null
}
