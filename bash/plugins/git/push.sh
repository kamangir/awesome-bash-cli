#! /usr/bin/env bash

function abcli_git_push() {
    local message="$1 - kamangir/bolt#746"

    local options=$2
    local in_object=$(abcli_option_int "$options" object 0)
    local do_delete=$(abcli_option_int "$options" delete 0)
    local do_increment_version=$(abcli_option_int "$options" plus 0)
    local show_status=$(abcli_option_int "$options" status 1)
    local first_push=$(abcli_option_int "$options" first 0)

    local repo_name=$(abcli_unpack_repo_name .)
    local path=$abcli_path_git/$repo_name
    [[ "$in_object" == 1 ]] && path=$abcli_object_path/$repo_name
    if [[ ! -d "$path" ]]; then
        abcli_log_error "-abcli: git: push: $repo_name: repo not found."
        return 1
    fi
    pushd $path >/dev/null

    [[ "$do_increment_version" == 1 ]] && abcli_git increment_version

    [[ "$show_status" == 1 ]] && git status

    git add .

    git commit -a -m "$message"

    if [ "$first_push" == 1 ]; then
        local branch_name=$(abcli_git_get_branch $repo_name $options)
        git push --set-upstream origin $branch_name
    else
        git push
    fi

    if [ "$do_delete" == 1 ]; then
        abcli_log "deleting $repo_name"
        cd ..
        rm -rf $repo_name
    fi

    popd >/dev/null

}
