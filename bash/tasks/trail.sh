#! /usr/bin/env bash

function abc_trail() {
    local task=$(abc_unpack_keyword "$1" help)

    if [ "$task" == "help" ] ; then
        abc_help_line "trail filename.log" \
            "trail filename.log."
        abc_help_line "trail stop" \
            "stop trailing."
        return
    fi

    if [ "$task" == "stop" ] ; then
        if [[ "$abc_rpi_model" != "pizero_w" ]] ; then
            sudo killall remote_syslog
        fi

        export abc_log_filename=""
        return
    fi

    local log_filename="$1"

    if [ "$log_filename" != "$abc_log_filename" ] ; then
        abc_trail stop

        if [ -f "$log_filename" ]; then
            sudo rm "$log_filename"
        fi
        touch "$log_filename"
        
        if [[ "$abc_rpi_model" != "pizero_w" ]] ; then
            sudo $abc_path_abc/assets/papertrail/remote_syslog/remote_syslog \
                -p 30742 \
                -d logs3.papertrailapp.com \
                --pid-file=/var/run/remote_syslog.pid \
                --hostname="$abc_fullname.$(hostname).$abc_host_name" \
                "$log_filename"
        fi
    fi

    export abc_log_filename=$log_filename
}

if [ -z "$abc_log_filename" ] ; then
    export abc_log_filename="abc.log"
fi