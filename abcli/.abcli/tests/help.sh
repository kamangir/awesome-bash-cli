#! /usr/bin/env bash

function test_abcli_help() {
    local options=$1

    local module
    for module in \
        "@badge" \
        \
        "@batch browse" \
        "@batch cat" \
        "@batch eval" \
        "@batch list" \
        "@batch submit" \
        \
        "@browse" \
        \
        "@build_README" \
        \
        "@cat" \
        \
        "@conda" \
        "@conda create" \
        "@conda exists" \
        "@conda list" \
        "@conda rm" \
        \
        "@docker browse " \
        "@docker build " \
        "@docker clear " \
        "@docker eval " \
        "@docker push " \
        "@docker run " \
        "@docker seed " \
        "@docker source " \
        \
        "@env" \
        "@env backup" \
        "@env backup list" \
        "@env dot" \
        "@env dot cat" \
        "@env dot cat" \
        "@env dot cp" \
        "@env dot edit" \
        "@env dot get" \
        "@env dot list" \
        "@env dot load" \
        "@env dot set" \
        \
        "@git" \
        "@git browse" \
        "@git checkout" \
        "@git clone" \
        "@git create_branch" \
        "@git create_pull_request" \
        "@git get_branch" \
        "@git get_repo_name" \
        "@git increment_version" \
        "@git pull" \
        "@git push" \
        "@git recreate_ssh" \
        "@git reset" \
        "@git review" \
        "@git rm" \
        "@git seed" \
        "@git status" \
        "@git sync_fork" \
        \
        "@gpu status get" \
        "@gpu status show" \
        "@gpu validate" \
        \
        "@init" \
        \
        "@instance" \
        "@instance from_image" \
        "@instance from_template" \
        "@instance get_ip" \
        "@instance list" \
        "@instance terminate" \
        \
        "@latex" \
        "@latex bibclean" \
        "@latex build" \
        "@latex install" \
        \
        "@list" \
        "@list filter" \
        "@list in" \
        "@list intersect " \
        "@list item" \
        "@list len " \
        "@list log " \
        "@list next" \
        "@list nonempty" \
        "@list prev" \
        "@list resize" \
        "@list sort" \
        \
        "@ls" \
        \
        "@pause" \
        \
        "@perform_action" \
        \
        "@plugins get_module_name" \
        "@plugins install" \
        "@plugins list_of_external" \
        "@plugins list_of_installed" \
        "@plugins transform" \
        \
        "abcli_publish" \
        "abcli_publish tar" \
        \
        "@pylint" \
        \
        "@pypi" \
        "@pypi browse" \
        "@pypi build" \
        "@pypi install" \
        \
        "@pytest" \
        \
        "@repeat" \
        \
        "@seed" \
        "@seed eject" \
        "@seed list" \
        \
        "@select" \
        \
        "@session" \
        "@session start" \
        \
        "@sleep" \
        \
        "@ssm" \
        "@ssm get" \
        "@ssm put" \
        "@ssm rm" \
        \
        "@storage" \
        "@storage clear" \
        "@storage download_file" \
        "@storage exists" \
        "@storage list" \
        "@storage rm" \
        "@storage status" \
        \
        "@test" \
        "@test list" \
        \
        "@terraform" \
        "@terraform cat" \
        "@terraform disable" \
        "@terraform enable" \
        \
        "@trail" \
        "@trail stop" \
        \
        "@watch" \
        \
        "abcli_log_list" \
        "abcli_source_caller_suffix_path" \
        "abcli_source_path" \
        \
        "abcli_blueness" \
        \
        "abcli"; do
        abcli_eval ,$options \
            abcli_help $module
        [[ $? -ne 0 ]] && return 1

        abcli_hr
    done

    return 0
}
