#! /usr/bin/env bash

function abcli_message() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli message listen_as <recipient>  [--sender <sender_1,sender_2>] [<args>]" \
            "listen as <recipient> to [<100>] messages [from <sender_1,sender_2>]."
        abcli_show_usage "abcli message submit [--data <data>] [--filename <filename>] [--recipient <host_1,host_2>] [--subject <subject>]" \
            "submit message [w/ subject] [+data] [+filename] [to host_1, host_2]."
        abcli_show_usage "abcli message update [--recipient host_1,host_2]" \
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
            listen_as \
            --recipient $recipient \
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