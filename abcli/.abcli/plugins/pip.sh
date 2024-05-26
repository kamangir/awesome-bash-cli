#! /usr/bin/env bash

function abcli_pip() {
    local task=$1

    if [[ "$task" == "help" ]]; then
        abcli_show_usage "abcli pip install <module>" \
            "install <module>."
        return
    fi

    if [ "$task" == "install" ]; then
        local module=$2

        python3 -c "import $module" &>/dev/null ||
            pip3 install $module

        return
    fi

    abcli_log_error "-abcli: pip: $task: command not found."
    return 1
}
