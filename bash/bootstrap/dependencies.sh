#! /usr/bin/env bash

function abcli_source_dependencies() {
    pushd $abcli_path_bash/bootstrap/config > /dev/null
    local filename
    for filename in *.sh ; do
        source $filename
    done
    popd > /dev/null

    source $abcli_path_bash/bootstrap/paths.sh
    source $abcli_path_bash/bootstrap/system.sh
    source $abcli_path_bash/bootstrap/logging.sh

    local module_name
    for module_name in abcli install modules plugins ; do
        pushd $abcli_path_bash/$module_name > /dev/null

        if [ "$module_name" == "plugins" ] ; then
            local plugins=(`ls *.sh`)
            local plugins=${plugins[*]}
            local plugins=$(python3 -c "print('$plugins'.replace('.sh',''))")
            abcli_log_list "$plugins" space "plugin(s)" "loading "
        fi

        local filename
        for filename in *.sh ; do
            source $filename
        done
        popd > /dev/null
    done

    local repo_name
    for repo_name in $(abcli_plugins list_of_external --log 0 --delim space --repo_names 1) ; do
        abcli_log "loading $repo_name"

        if [ ! -d "$abcli_path_git/$repo_name" ] ; then
            abcli_git clone $repo_name
        fi

        pushd $abcli_path_git/$repo_name/abcli > /dev/null
        local filename
        for filename in *.sh ; do
            source $filename
        done
        popd > /dev/null
    done
}