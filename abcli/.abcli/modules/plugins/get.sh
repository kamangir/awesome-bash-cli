#! /usr/bin/env bash

function abcli_plugin_name_from_repo() {
    local repo_name=${1:-.}

    [[ "$repo_name" == "." ]] && repo_name=$(abcli_git_get_repo_name)

    python3 -m abcli.plugins \
        get_plugin_name \
        --repo_name $repo_name \
        "${@:2}"
}

function abcli_get_module_name_from_plugin() {
    local plugin_name=$1

    local var_name=${plugin_name}_module_name
    local module_name=${!var_name}

    [[ -z "$module_name" ]] && module_name=$plugin_name

    echo $module_name
}

function abcli_get_repo_name_from_plugin() {
    local plugin_name=$(echo "$1" | tr _ -)

    local var_name=${plugin_name}_repo_name
    local repo_name=${!var_name}

    [[ -z "$repo_name" ]] && repo_name=$plugin_name

    echo $repo_name
}
