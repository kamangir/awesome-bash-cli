#! /usr/bin/env bash

function abcli_message() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli message listen_as$ABCUL<recipient>$ABCUL[--sender <sender_1,sender_2>]$ABCUL[<args>]" \
            "listen as <recipient> to [<100>] messages [from <sender_1,sender_2>]."
        abcli_show_usage "abcli message submit$ABCUL[--data <data>]$ABCUL[--filename <filename>]$ABCUL[--recipient <host_1,host_2>]$ABCUL[--subject <subject>]" \
            "submit message [w/ subject] [+data] [+filename] [to host_1, host_2]."
        abcli_show_usage "abcli message submit object$ABCUL[<object-name>]$ABCUL[<recipient>]" \
            "submit all the images in <object-name> to <recipient>."
        abcli_show_usage "abcli message update$ABCUL[--recipient host_1,host_2]" \
            "send update message [to host_1, host_2]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.plugins.message --help
        fi
        return
    fi

    if [ $task == "listen_as" ]; then
        local recipient=$2
        if [ "$recipient" == "." ]; then
            local recipient=$abcli_host_name
        fi

        python3 -m abcli.plugins.message \
            listen_as \
            --recipient $recipient \
            ${@:3}
        return
    fi

    if [ $task == "submit" ]; then
        local subtask="$2"

        if [ $subtask == "object" ]; then
            local object_name=$(abcli_clarify_object $3 .)
            local recipient=$(abcli_clarify_input $4 stream)

            abcli_log "abcli: stream: $object_name -> $recipient"

            abcli_download - $object_name

            python3 -m abcli.plugins.message \
                submit_object \
                --object_name "$object_name" \
                --recipient "$recipient" \
                "${@:5}"

            return
        fi

        python3 -m abcli.plugins.message \
            submit \
            ${@:2}
        return
    fi

    if [ $task == "update" ]; then
        python3 -m abcli.plugins.message \
            update \
            ${@:2}
        return
    fi

    abcli_log_error "-abcli: message: $task: command not found."
    return 1
}
