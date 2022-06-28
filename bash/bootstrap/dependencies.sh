#! /usr/bin/env bash

function abcli_source_dependencies() {
    source $abcli_path_bash/bootstrap/consts.sh
    source $abcli_path_bash/bootstrap/logging.sh

    local module_name
    local script_filename
    for module_name in abcli install tasks plugins ; do
        local list_of_scripts=$(ls $abcli_path_bash/$module_name/*.sh)

        if [ "$module_name" == "plugins" ] ; then
            local external_plugins=$(python3 -m abcli.plugins \
                list_of_external \
                --delim space)

            local plugin_names="$external_plugins"
            for script_filename in $list_of_scripts ; do
                local plugin_names="$plugin_names $(basename $script_filename .sh)"
            done
            abcli_log_list "$plugin_names" space "plugin(s)" "loading "

            local external_scripts=$(python3 -c "import os.path; print(' '.join([os.path.join('$abcli_path_git',repo,'abcli/plugin.sh') for repo in '$external_plugins'.split(' ') if repo]))")
            local list_of_scripts="$list_of_scripts $external_scripts"
        fi

        for script_filename in $list_of_scripts ; do
            source $script_filename
        done
    done

    export abcli_external_repo_list="$external_plugins"
}
