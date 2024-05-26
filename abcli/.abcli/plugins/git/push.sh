#! /usr/bin/env bash

function abcli_git_push() {
    local message=$1
    if [[ -z "$message" ]]; then
        abcli_log_error "-@git: push: message not found."
        return 1
    fi

    local options=$2
    local do_browse=$(abcli_option_int "$options" browse 0)
    local do_increment_version=$(abcli_option_int "$options" increment_version 1)
    local show_status=$(abcli_option_int "$options" status 1)
    local first_push=$(abcli_option_int "$options" first 0)
    local create_pull_request=$(abcli_option_int "$options" create_pull_request $first_push)
    local do_action=$(abcli_option_int "$options" action 1)

    [[ "$do_increment_version" == 1 ]] &&
        abcli_git increment_version

    [[ "$show_status" == 1 ]] &&
        git status

    local repo_name=$(abcli_git_get_repo_name)
    local plugin_name=$(abcli_plugin_name_from_repo $repo_name)

    [[ "$do_action" == 1 ]] &&
        abcli_perform_action \
            action=git_before_push,plugin=$plugin_name

    git add .

    git commit -a -m "$message - kamangir/bolt#746"

    if [ "$first_push" == 1 ]; then
        git push \
            --set-upstream origin $(abcli_git get_branch)
    else
        git push
    fi

    [[ "$create_pull_request" == 1 ]] &&
        abcli_git create_pull_request

    [[ "$do_browse" == 1 ]] &&
        abcli_git browse actions

    local build_options=$3
    [[ $(abcli_option_int "$build_options" build 0) == 1 ]] &&
        abcli_pypi_build $build_options,plugin=$plugin_name

    return 0
}
