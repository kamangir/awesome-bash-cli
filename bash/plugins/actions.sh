#! /usr/bin/env bash

function abcli_perform_action() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="action=<action-name>,plugin=<plugin-name>"
        abcli_show_usage "@perform_action $options$ABCUL<args>" \
            "perform the action."
        return
    fi

    local action_name=$(abcli_option "$options" action void)
    local plugin_name=$(abcli_option "$options" plugin abcli)

    local function_name=${plugin_name}_action_${action_name}

    [[ $(type -t $function_name) != "function" ]] &&
        return 0

    abcli_log "✴️  action: $plugin_name: $action_name."
    $function_name "${@:2}"
}

function abcli_action_git_before_push() {
    [[ "$(abcli_git get_branch)" == "current" ]] &&
        abcli pypi build
}
