#! /usr/bin/env bash

function abcli_source_dependencies() {
    source $abcli_path_bash/bootstrap/paths.sh
    source $abcli_path_bash/bootstrap/system.sh
    source $abcli_path_bash/bootstrap/logging.sh

    local module_name
    local script_filename
    for module_name in abcli install tasks plugins ; do
        local list_of_scripts=$(ls $abcli_path_bash/$module_name/*.sh)

        if [ "$module_name" == "plugins" ] ; then
            local external_plugins=$(abcli_external_plugins space)

            local plugin_names="$external_plugins"
            for script_filename in $list_of_scripts ; do
                local plugin_names="$plugin_names $(basename $script_filename .sh)"
            done
            abcli_log_list "$plugin_names" space "plugin(s)" "loading "

            local plugin_name
            for plugin_name in $external_plugins ; do
                local repo_name=$(echo "$plugin_name" | tr _ -)
                local list_of_scripts="$list_of_scripts $(ls $abcli_path_git/$repo_name/abcli/*.sh)"
            done
        fi

        for script_filename in $list_of_scripts ; do
            source $script_filename
        done

    done

    export abcli_external_repo_list="$external_plugins"
}
