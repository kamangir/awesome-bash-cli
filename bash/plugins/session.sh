#! /usr/bin/env bash

function abcli_session() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli session get" \
            "get session plugin name."
        abcli_show_usage "abcli session set <plugin-name>" \
            "set <plugin_name> as the session."
        abcli_show_usage "abcli session start [~pull] [<args>]" \
            "[do't pull repos and] start the session [w/ <args>]."
        return
    fi

    if [ "$task" == "get" ] ; then
        abcli_cookie read session
        return
    fi

    if [ "$task" == "set" ] ; then
        local plugin_name=$2
        abcli_cookie write session $plugin_name
        return
    fi

    if [ $task == "start" ] ; then
        local options=$2

        local do_pull=1
        if [ "$abcli_is_mac" == true ] ; then
            local do_pull=0
        fi
        local do_pull=$(abcli_option_int "$options" pull $do_pull)

        abcli_log "session started: $options ${@:3}"

        while true; do
            if [ "$do_pull" == 1 ] ; then
                abcli_git_pull init
            fi

            abcli_log "session initialized: username=$USER, hostname=$(hostname), EUID=$EUID"

            rm $abcli_path_cookie/session_reply_*

            if [[ "$abcli_is_mac" == false ]] ; then
                abcli_storage clear
            fi

            abcli_select

            local plugin_name=$(abcli_session get)
            if [[ $(type -t ${plugin_name}_session) == "function" ]] ; then
                eval ${plugin_name}_session start ${@:3}
            else
                if [ -z "$plugin_name" ] ; then
                    abcli_log_warning "-session: plugin not found."
                else
                    abcli_log_error "-session: plugin: $plugin_name: plugin not found."
                fi
                abcli_sleep 60s
            fi

            abcli_log "session closed."

            if [ -f "$abcli_path_cookie/session_reply_exit" ] ; then
                abcli_log "abcli.reply_to_bash(exit)"
                return
            fi

            if [ -f "$abcli_path_cookie/session_reply_reboot" ] ; then
                abcli_log "abcli.reply_to_bash(reboot)"
                abcli_host reboot
            fi

            if [ -f "$abcli_path_cookie/session_reply_seed" ] ; then
                abcli_log "abcli.reply_to_bash(seed)"

                abcli_git_pull
                abcli_init

                cat "$abcli_path_cookie/session_reply_seed" | while read line 
                do
                    abcli_log "executing: $line"
                    eval $line
                done
            fi

            if [ -f "$abcli_path_cookie/session_reply_shutdown" ] ; then
                abcli_host shutdown
            fi

            if [ -f "$abcli_path_cookie/session_reply_update" ] ; then
                abcli_log "abcli.reply_to_bash(update)"
            fi

            if [ -f "$abcli_path_bash/bootstrap/cookie/disabled" ] ; then
                abcli_log "abcli is disabled."
                return
            fi

            abcli_sleep 5s
        done

        return
    fi

    abcli_log_error "-abcli: session: $task: command not found."
}