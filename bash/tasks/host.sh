#! /usr/bin/env bash

function abcli_host() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name host get name" \
            "get $abcli_host_name."
        abcli_help_line "$abcli_cli_name host get tags [host_name_1]" \
            "get $abcli_host_name/host_name_1 tags."
        abcli_help_line "$abcli_cli_name host loop [force]" \
            "[force] start a loop."
        abcli_help_line "$abcli_cli_name host reboot [host_name_1,host_name_2]" \
            "reboot $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "$abcli_cli_name host shutdown [host_name_1,host_name_2]" \
            "shutdown $abcli_host_name/host_name_1,host_name_2."
        abcli_help_line "$abcli_cli_name host tag tag_1,~tag_2 [host_name_1]" \
            "tag [host_name_1] tag_1,~tag_2."
        abcli_help_line "$abcli_cli_name host tag as host_type_1" \
            "tag [host_name_1] as host_type_1."

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
            --name $(abcli_clarify_arg "$3" ".") \
            ${@:4}
        return
    fi

    if [ $task == "loop" ] ; then
        local mode="$2"
        abcli_log "loop started: $mode"

        while true; do
            if [[ $(abcli_list_in main $abcli_host_tags) == "True" ]] ; then
                abcli_git . checkout main
            fi

            abcli_git_pull init

            abcli_log "loop initialized."

            rm $abcli_path_abcli/abcli_host_return_to_bash_*

            if [[ "$abcli_is_rpi" == true ]] || [[ "$abcli_is_ubuntu" == true ]] || [[ "$abcli_is_ec2" == true ]] ; then
                abcli_storage clear
            fi

            abcli_select

            local found=false
            local tags=$(echo "$abcli_host_tags" | tr , " ")
            for tag in $tags ; do
                if [ "$tag" == "void" ] && [ -z "$mode" ] ; then
                    abcli_log "void tag detected."
                    return
                fi

                local filename=$abcli_path_git/abcli/host/$tag.sh
                if [ -f $filename ] ; then
                    abcli_log "-> $filename"
                    source $filename

                    local found=true
                    break
                fi

                local repo
                for repo in abcli $(echo "$abcli_tagged_external_plugins" | tr _ - | tr , " ") ; do
                    local filename=$abcli_path_git/$repo/abcli/host/$tag.sh
                    if [ -f $filename ] ; then
                        abcli_log "-> $filename"
                        source $filename

                        local found=true
                        break
                    fi
                done

                if [ "$found" == true ] ; then
                    break
                fi
            done

            if [ "$found" == false ] ; then
                abcli_log "no instruction file, loop started."

                abcli_tag set $abcli_object_name loop,$abcli_host_tags,$abcli_host_name,$(abcli_string_today),$abcli_fullname,open,$abcli_wifi_ssid

                if [[ "$abcli_is_rpi" == true ]] ; then
                    LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libatomic.so.1 \
                    python3 -m abcli.loop ${@:3}
                else
                    python3 -m abcli.loop ${@:3}
                fi

                abcli_upload open

                abcli_log "loop ended."
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_exit" ] ; then
                abcli_log "abcli.return_to_bash(exit)"
                return
            fi

            if [ -f "$abcli_path_abcli/abcli_host_return_to_bash_reboot" ] ; then
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

        done

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