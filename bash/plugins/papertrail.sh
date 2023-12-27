#! /usr/bin/env bash

function abcli_trail() {
    local task=$(abcli_unpack_keyword "$1" help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli trail <filename>" \
            "trail filename."
        abcli_show_usage "abcli trail stop" \
            "stop trailing."
        return
    fi

    [[ "$abcli_is_in_notebook" == true ]] && return

    if [ "$task" == "stop" ]; then
        abcli_killall remote_syslog
        export abcli_log_filename=""
        return
    fi

    local log_filename="$1"

    if [ "$log_filename" != "$abcli_log_filename" ]; then
        abcli_trail stop

        if [ -f "$log_filename" ]; then
            sudo rm "$log_filename"
        fi
        touch "$log_filename"

        local prefix
        [[ "$abcli_is_docker" == false ]] &&
            [[ "$abcli_is_aws_batch" == false ]] && prefix=sudo

        $prefix $abcli_path_abcli/assets/papertrail/remote_syslog/remote_syslog \
            -p $abcli_papertrail_dest_port \
            -d $abcli_papertrail_dest_host \
            --pid-file=/var/run/remote_syslog.pid \
            --hostname="$abcli_fullname.$abcli_hostname.$abcli_host_name" \
            "$log_filename"
    fi

    export abcli_log_filename=$log_filename
}
