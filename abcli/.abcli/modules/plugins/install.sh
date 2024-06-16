#! /usr/bin/env bash

function abcli_plugins_install() {
    local plugin_name=$(abcli_unpack_keyword "$1")

    if [[ "$plugin_name" == help ]]; then
        abcli_show_usage "@plugins install$ABCUL<plugin-name>" \
            "install <plugin-name>."
        return
    fi

    local repo_name=$(abcli_get_repo_name_from_plugin $plugin_name)
    if [[ -z "$repo_name" ]]; then
        abcli_log_error "-@plugins: install: $plugin_name: plugin not found."
        return 1
    fi

    abcli_log "installing $plugin_name from $repo_name"

    pushd $abcli_path_git/$repo_name >/dev/null
    pip3 install -e .
    pip3 install -r requirements.txt
    popd >/dev/null
}
