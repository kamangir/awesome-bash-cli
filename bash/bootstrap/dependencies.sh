#! /usr/bin/env bash

function abcli_source_dependencies() {
    source $abcli_path_bash/bootstrap/consts.sh
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
    export abcli_external_plugins=$(abcli_list_intersect $abcli_host_tags $external_plugins)

    local plugin_name
    for plugin_name in $(echo $abcli_external_plugins | tr , " ") ; do
        abcli_log "loading $plugin_name"
        local repo_name=$(echo "$plugin_name" | tr _ -)

        pushd $abcli_path_git/$repo_name/abcli > /dev/null
        local filename
        for filename in *.sh ; do
            source $filename
        done
        popd > /dev/null
    done
}


# 
# 
# local plugin_names="$external_plugins"
# for script_filename in $list_of_scripts ; do
#     local plugin_names="$plugin_names $(basename $script_filename .sh)"
# done
# abcli_log_list "$plugin_names" space "plugin(s)" "loading "
# 

