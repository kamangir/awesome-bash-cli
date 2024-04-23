#! /usr/bin/env bash

function abcli_plugins() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli plugins install [<plugin-name>]" \
            "install <plugin-name>|all plugins."
        abcli_show_usage "abcli plugins is_present <plugin-name>" \
            "is <plugin-name> present?"
        abcli_show_usage "abcli plugins list_of_external" \
            "show list of expernal plugins."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.plugins --help
        fi
        return
    fi

    if [ $task == "install" ]; then
        local plugin_name=$(abcli_unpack_keyword "$2")

        if [ -z "$plugin_name" ]; then
            local plugin_name
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
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: plugins: $task: command not found."
    return 1
}
