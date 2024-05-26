#! /usr/bin/env bash

function abcli_host() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli host get name" \
            "get $abcli_host_name."
        abcli_show_usage "abcli host get tags [<host_name>]" \
            "get $abcli_host_name/host_name tags."
        abcli_show_usage "abcli host reboot [<host_name_1,host_name_2>]" \
            "reboot $abcli_host_name/host_name_1,host_name_2."
        abcli_show_usage "abcli host shutdown [<host_name_1,host_name_2>]" \
            "shutdown $abcli_host_name/host_name_1,host_name_2."
        abcli_show_usage "abcli host tag <tag_1,~tag_2> [<host_name>]" \
            "tag [host_name] tag_1,~tag_2."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.modules.host --help
        fi
        return
    fi

    if [ $task == "get" ]; then
        python3 -m abcli.modules.host \
            get \
            --keyword "$2" \
            --name $(abcli_clarify_input "$3" .) \
            ${@:4}
        return
    fi

    if [ $task == "reboot" ]; then
        local recipient="$2"
        if [ "$recipient" == "$abcli_host_name" ]; then
            local recipient=""
        fi

        if [ -z "$recipient" ]; then
            if [[ "$abcli_is_mac" == false ]]; then
                abcli_log "rebooting..."
                sudo reboot
            fi
        else
            python3 -m abcli.plugins.message \
                submit \
                --subject reboot \
                --recipient $recipient
        fi

        return
    fi

    if [ $task == "shutdown" ]; then
        local recipient="$2"
        if [ "$recipient" == "$abcli_host_name" ]; then
            local recipient=""
        fi

        if [ -z "$recipient" ]; then
            if [[ "$abcli_is_mac" == false ]]; then
                abcli_log "shutting down."
                sudo shutdown -h now
            fi
        else
            python3 -m abcli.plugins.message \
                submit \
                --subject shutdown \
                --recipient $recipient
        fi
        return
    fi

    if [ $task == "tag" ]; then
        local tags=$2

        local host_name=$3
        if [ -z "$host_name" ] || [ "$host_name" == "." ]; then
            local host_name=$abcli_host_name
        fi

        abcli_tag set $host_name $tags

        return
    fi

    abcli_log_error "-abcli: host: $task: command not found."
    return 1
}
