#! /usr/bin/env bash

function abcli_host() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name host get name" \
            "get $abcli_host_name."
        abcli_help_line "$abcli_cli_name host get tags [<host_name>]" \
            "get $abcli_host_name/host_name tags."
        abcli_help_line "$abcli_cli_name host reboot [<host_name_1,host_name_2>]" \
            "reboot $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "$abcli_cli_name host shutdown [<host_name_1,host_name_2>]" \
            "shutdown $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "$abcli_cli_name host tag <tag_1,~tag_2> [<host_name>]" \
            "tag [host_name] tag_1,~tag_2."
        abcli_help_line "$abcli_cli_name host tag as <host_type> [<host_name>]" \
            "tag [host_name] as host_type."

        local host_tag_list=""
        local host_tag
        for host_tag in $abcli_path_abcli/host/*.sh $abcli_path_abcli/host/*.json ; do
            local host_tag=$(basename -- "$host_tag")
            local host_tag=${host_tag%.*}
            local host_tag_list="$host_tag_list,$host_tag"
        done
        local host_tag_list=$(abcli_list_sort "$host_tag_list" --unique 1)
        abcli_log_list "$host_tag_list" , "host tag(s)"

        local host_type_list=$(python3 -m abcli.plugins.tags list_of_types --delim , --log 0)
        abcli_log_list "$host_type_list" , "host type(s)"

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.tasks.host --help
        fi
        return
    fi

    if [ $task == "get" ] ; then
        python3 -m abcli.tasks.host \
            get \
            --keyword "$2" \
            --name $(abcli_clarify_arg "$3" .) \
            ${@:4}
        return
    fi

    if [ $task == "reboot" ] ; then
        local recipient="$2"
        if [ "$recipient" == "$abcli_host_name" ] ; then
            local recipient=""
        fi

        if [ -z "$recipient" ] ; then
            if [[ "$abcli_is_mac" == false ]]; then
                abcli_log "rebooting..."
                sudo reboot
            fi
        else
            python3 -m abcli.message \
                submit \
                --event reboot \
                --recipient $recipient
        fi

        return
    fi

    if [ $task == "shutdown" ] ; then
        local recipient="$2"
        if [ "$recipient" == "$abcli_host_name" ] ; then
            local recipient=""
        fi

        if [ -z "$recipient" ] ; then
            if [[ "$abcli_is_mac" == false ]]; then
                abcli_log "shutting down."
                sudo shutdown -h now
            fi
        else
            python3 -m abcli.message \
                submit \
                --event shutdown \
                --recipient $recipient
        fi
        return
    fi

    if [ $task == "tag" ] ; then
        local tags=$2

        local host_name=$3
        if [ "$tags" == "as" ] ; then
            local tags=$(python3 -m abcli.plugins.tags for_type --type $3 --delim , --log 0)
            local host_name=$4
        fi

        if [ -z "$host_name" ] || [ "$host_name" == "." ] ; then
            local host_name=$abcli_host_name
        fi
            
        abcli_tag set $host_name $tags

        return
    fi

    abcli_log_error "-abcli: host: $task: command not found."
}