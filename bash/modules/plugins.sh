#! /usr/bin/env bash

function abcli_plugins() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "@plugins install [<plugin-name>]" \
            "install <plugin-name>|all plugins."

        abcli_show_usage "@plugins is_present <plugin-name>" \
            "is <plugin-name> present?"

        abcli_show_usage "@plugins list_of_external" \
            "show list of expernal plugins."

        [[ "$(abcli_keyword_is $2 verbose)" == true ]] &&
            python3 -m abcli.plugins --help

        return 0
    fi

    if [ $task == "install" ]; then
        local plugin_name=$(abcli_unpack_keyword "$2")

        if [ -z "$plugin_name" ]; then
            for plugin_name in $(abcli_plugins list_of_external --log 0 --delim space); do
                abcli_plugins install $plugin_name
            done
        else
            local repo_name=$(echo "$plugin_name" | tr _ -)
            pushd $abcli_path_git/$repo_name >/dev/null
            pip3 install -e .
            pip3 install -r requirements.txt
            popd >/dev/null
        fi

        return
    fi

    if [ $task == "is_present" ]; then
        local plugin_name=$2

        local list_of_plugins=$(abcli_plugins list_of_external --delim , --log 0)

        abcli_list_in $plugin_name $list_of_plugins
        return
    fi

    if [ $task == "list_of_external" ]; then
        python3 -m abcli.plugins \
            list_of_external \
            "${@:2}"
        return
    fi

    abcli_log_error "-@plugins: $task: command not found."
    return 1
}

function abcli_plugin_name_from_repo() {
    local repo_name=${1:-.}

    [[ "$repo_name" == "." ]] && repo_name=$(abcli_git_get_repo_name)

    local plugin_name=$(echo "$repo_name" | tr - _)

    [[ "$plugin_name" == "awesome_bash_cli" ]] && plugin_name="abcli"

    echo $plugin_name
}

function abcli_get_module_name_from_plugin() {
    local module_name=$1

    [[ "$module_name" == "CV" ]] && module_name="abadpour"
    [[ "$module_name" == "giza" ]] && module_name="gizai"
    [[ "$module_name" == "hubble" ]] && module_name="hubblescope"
    [[ "$module_name" == "aiart" ]] && module_name="articraft"

    echo $module_name
}
