#! /usr/bin/env bash

function abcli_source_dependencies() {
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

        export abcli_host_tags=$(abcli_host get tags . --delim , --log 0)
        local external_plugins=$(abcli_external_plugins --delim ,)

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
# local plugin_name
# for plugin_name in $external_plugins ; do
#     local repo_name=$(echo "$plugin_name" | tr _ -)
#     local list_of_scripts="$list_of_scripts $(ls $abcli_path_git/$repo_name/abcli/*.sh)"
# done
