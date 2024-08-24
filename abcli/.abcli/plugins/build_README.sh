#! /usr/bin/env bash

function abcli_build_README() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="push"
        [[ "$plugin_name" == "abcli" ]] &&
            options="$options,plugin=<plugin-name>"
        abcli_show_usage "$plugin_name build_README [$options]" \
            "build $plugin_name/README.md."
        return
    fi

    local do_push=$(abcli_option_int "$options" push 0)

    local repo_name=$(abcli_unpack_repo_name $plugin_name)
    local module_name=$(abcli_plugins get_module_name $repo_name)

    python3 -m $module_name \
        build_README \
        "${@:2}"
    [[ $? -ne 0 ]] && return 1

    if [[ "$do_push" == 1 ]]; then
        abcli_git $repo_name push \
            "$(python3 -m $module_name version) build"
    else
        abcli_git $repo_name status ~all
    fi
}
