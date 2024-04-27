#! /usr/bin/env bash

function abcli_pytest() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="dryrun,list,~log,plugin=<plugin-name>,show_warning,~verbose"
        abcli_show_usage "$plugin_name pytest$ABCUL[$options]$ABCUL[filename.py|filename.py::test]" \
            "pytest $plugin_name."
        return
    fi

    local args="${@:2}"

    [[ $(abcli_option_int "$options" list 0) == 1 ]] &&
        local args="$args --collect-only"

    [[ $(abcli_option_int "$options" show_warning 0) == 0 ]] &&
        local args="$args --disable-warnings"

    [[ $(abcli_option_int "$options" verbose 1) == 1 ]] &&
        local args="$args --verbose"

    local repo_name=$(abcli_unpack_repo_name $plugin_name)
    abcli_log "$plugin_name: pytest: repo=$repo_name"

    # https://stackoverflow.com/a/40720333/17619982
    abcli_eval "path=$abcli_path_git/$repo_name,$options" \
        python3 -m pytest "$args"
}

# https://stackoverflow.com/a/40724361/10917551
# --disable-pytest-warnings"
