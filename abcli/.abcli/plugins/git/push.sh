#! /usr/bin/env bash

function abcli_git_push() {
    local message=$1

    local options=$2

    if [[ "$message" == "help" ]]; then
        options="$EOP~action,browse,~create_pull_request,${EOPE}first$EOP,~increment_version,~status$EOPE"
        local build_options="build,$abcli_pypi_build_options"
        abcli_show_usage "@git push <message>$ABCUL$options$ABCUL$build_options" \
            "push to the repo."
        return
    fi

    if [[ -z "$message" ]]; then
        abcli_log_error "-@git: push: message not found."
        return 1
    fi

    local do_browse=$(abcli_option_int "$options" browse 0)
    local do_increment_version=$(abcli_option_int "$options" increment_version 1)
    local show_status=$(abcli_option_int "$options" status 1)
    local first_push=$(abcli_option_int "$options" first 0)
    local create_pull_request=$(abcli_option_int "$options" create_pull_request $first_push)
    local do_action=$(abcli_option_int "$options" action 1)

    [[ "$do_increment_version" == 1 ]] &&
        abcli_git_increment_version
    [[ $? -ne 0 ]] && return 1

    [[ "$show_status" == 1 ]] &&
        git status

    local repo_name=$(abcli_git_get_repo_name)
    local plugin_name=$(abcli_plugin_name_from_repo $repo_name)

    if [[ "$do_action" == 1 ]]; then
        abcli_perform_action \
            action=git_before_push,plugin=$plugin_name
        [[ $? -ne 0 ]] && return 1
    fi

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
        abcli_git_browse . actions

    local build_options=$3
    [[ $(abcli_option_int "$build_options" build 0) == 1 ]] &&
        abcli_pypi_build $build_options,plugin=$plugin_name

    return 0
}
