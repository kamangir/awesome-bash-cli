#! /usr/bin/env bash

function abcli_trail() {
    local task=$(abcli_unpack_keyword "$1" help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name trail filename.log" \
            "trail filename.log."
        abcli_help_line "$abcli_cli_name trail stop" \
            "stop trailing."
        return
    fi

    if [ "$task" == "stop" ] ; then
        if [[ "$abcli_rpi_model" != "pizero_w" ]] ; then
            sudo killall remote_syslog
        fi

        export abcli_log_filename=""
        return
    fi

    local log_filename="$1"

    if [ "$log_filename" != "$abcli_log_filename" ] ; then
        abcli_trail stop

        if [ -f "$log_filename" ]; then
            sudo rm "$log_filename"
        fi
        touch "$log_filename"
        
        if [[ "$abcli_rpi_model" != "pizero_w" ]] ; then
            sudo $abcli_path_abcli/assets/papertrail/remote_syslog/remote_syslog \
                -p $abcli_papertrail_dest_port \
                -d $abcli_papertrail_dest_host \
                --pid-file=/var/run/remote_syslog.pid \
                --hostname="$abcli_fullname.$(hostname).$abcli_host_name" \
                "$log_filename"
        fi
    fi

    export abcli_log_filename=$log_filename
}