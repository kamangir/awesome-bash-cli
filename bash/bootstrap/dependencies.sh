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
    for module_name in abcli install tasks plugins ; do
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

    export abcli_host_tags=$(abcli_host get tags . --delim , --log 0)

    local external_plugins=$(abcli_external_plugins --delim ,)
    export abcli_tagged_external_plugins=$(abcli_list_intersect $abcli_host_tags $external_plugins)

    local repo_name
    for repo_name in $(echo $abcli_tagged_external_plugins | tr _ - | tr , " ") ; do
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