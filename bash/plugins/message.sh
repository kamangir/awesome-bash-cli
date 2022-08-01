#! /usr/bin/env bash

function abcli_message() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name message listen_to <host_name>" \
            "listen to host_name messages."
        abcli_help_line "$abcli_cli_name message listen_as <host_name>" \
            "listen to messages as host_name."
        abcli_help_line "$abcli_cli_name message submit [--data <data>] [--filename <filename>] [--recipient <host_1,host_2>] [--subject <subject>]" \
            "submit message [w/ subject] [+data] [+filename] [to host_1, host_2]."
        abcli_help_line "$abcli_cli_name message update [--recipient host_1,host_2]" \
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