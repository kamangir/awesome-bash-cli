#! /usr/bin/env bash

function abcli_host() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli host get name" \
            "get $abcli_host_name."
        abcli_help_line "abcli host get tags [<host_name>]" \
            "get $abcli_host_name/host_name tags."
        abcli_help_line "abcli host reboot [<host_name_1,host_name_2>]" \
            "reboot $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "abcli host set_session <plugin-name>" \
            "set <plugin_name> as the session."
        abcli_help_line "abcli host shutdown [<host_name_1,host_name_2>]" \
            "shutdown $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "abcli start_session [~pull] [<args>]" \
            "[do't pull repos and] start a host session [w/ <args>]."
        abcli_help_line "abcli host tag <tag_1,~tag_2> [<host_name>]" \
            "tag [host_name] tag_1,~tag_2."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.modules.host --help
        fi
        return
    fi

    if [ $task == "get" ] ; then
        python3 -m abcli.modules.host \
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

    if [ "$task" == "set_session" ] ; then
        local plugin_name=$2
         abcli_cookie write "['session']" "'$plugin_name'"
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

    if [ $task == "start_session" ] ; then
        local options=$2
        local do_pull=$(abcli_option_int "$options" "pull" 1)

        abcli_log "host: session started: $options: ${@:3}"

        while true; do
            if [ "$do_pull" == 1 ] ; then
                abcli_git_pull init
            fi

            abcli_log "host: session initialized."

            rm $abcli_path_abcli/abcli_host_return_to_bash_*

            if [[ "$abcli_is_rpi" == true ]] || [[ "$abcli_is_ubuntu" == true ]] || [[ "$abcli_is_ec2" == true ]] ; then
                abcli_storage clear
            fi

            abcli_select

            local plugin_name=$(abcli_cookie read ".get('session','')")
            if [ ! -z "$plugin_name" ] ; then
                eval ${plugin_name}_start_session
            fi

            abcli_log "host: session closed."

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_exit" ] ; then
                abcli_log "abcli.return_to_bash(exit)"
                return
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_reboot" ] ; then
                abcli_log "abcli.return_to_bash(reboot)"
                abcli_host reboot
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_seed" ] ; then
                abcli_log "abcli.return_to_bash(seed)"

                abcli_git_pull
                abcli_init

                cat "$abcli_path_abcli/abcli_host_return_to_bash_seed" | while read line 
                do
                    abcli_log "executing: $line"
                    bash "$line"
                done
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_shutdown" ] ; then
                abcli_host shutdown
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_update" ] ; then
                abcli_log "abcli.return_to_bash(update)"
            fi

            local wait=5s
            abcli_log_local "pausing for $wait ... (Ctrl+C to stop)"
            sleep $wait
        done

        return
    fi

    if [ $task == "tag" ] ; then
        local tags=$2

        local host_name=$3
        if [ -z "$host_name" ] || [ "$host_name" == "." ] ; then
            local host_name=$abcli_host_name
        fi
            
        abcli_tag set $host_name $tags

        return
    fi

    abcli_log_error "-abcli: host: $task: command not found."
}