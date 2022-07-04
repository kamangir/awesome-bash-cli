#! /usr/bin/env bash

function abcli_message() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "message listen_to host_1" \
            "listen to host_1 messages."
        abcli_help_line "message listen_as host_1" \
            "listen to messages as host_1."
        abcli_help_line "message submit [--data data] [--filename filename_1] [--recipient host_1,host_2] [--subject subject_1]" \
            "submit message [w/ subject_1] [+data] [+filename_1] [to host_1, host_2]."
        abcli_help_line "message update [--recipient host_1,host_2]" \
            "send update message [to host_1, host_2]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.message --help
        fi
        return
    fi

    if [ $task == "listen_as" ] ; then
        local recipient=$2
        if [ "$recipient" == "." ] ; then
            local recipient=$abcli_host_name
        fi

        python3 -m abcli.plugins.message \
            listen_to \
            --recipient $recipient \
            ${@:3}
        return
    fi

    if [ $task == "listen_to" ] ; then
        local sender=$2
        if [ "$sender" == "." ] ; then
            local sender=$abcli_host_name
        fi

        python3 -m abcli.plugins.message \
            listen_to \
            --sender $sender \
            ${@:3}
        return
    fi

    if [ $task == "submit" ] ; then
        python3 -m abcli.plugins.message \
            submit \
            ${@:2}
        return
    fi

    if [ $task == "update" ] ; then
        python3 -m abcli.plugins.message \
            update \
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: message: $task: command not found."
}