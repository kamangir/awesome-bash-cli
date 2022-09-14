#! /usr/bin/env bash

function abcli_cookie() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli cookie cat [<cookie-name>|template]" \
            "cat cookie|<cookie-name>|template."
        abcli_help_line "abcli cookie cat jetson_nano|rpi <machine-name>" \
            "cat cookie from jetson_nano|rpi <machine-name>."
        abcli_help_line "abcli cookie copy <cookie-name> [jetson_nano|rpi] [<machine-name>]" \
            "cp <cookie-name> [to  jetson_nano|rpi <machine-name>]."
        abcli_help_line "abcli cookie edit [jetson_nano|rpi] [<machine-name>]" \
            "edit cookie on local|[jetson_nano|rpi <machine-name>]."
        abcli_help_line "abcli cookie list" \
            "list sample cookies."
        abcli_help_line "abcli cookie read <keyword> [<default>]" \
            "read <keyword> from cookie."
        abcli_help_line "abcli cookie write <keyword> <value>" \
            "write <keyword> = <value> in cookie."

        return
    fi

    if [ "$task" == "cat" ] ; then
        local cookie_name=$(abcli_clarify_input $2)

        if [ -z "$cookie_name" ] ; then
            local filename=$abcli_path_cookie/cookie.json
        elif [ "$(abcli_list_in $cookie_name rpi,jetson_nano)" == True ]] ; then
            local machine_kind=$2
            local machine_name=$3

            local filename="$abcli_object_path/scp-${machine_kind}-${machine_name}-cookie.json"

            abcli_scp \
                $machine_kind \
                $machine_name \
                \~/git/awesome-bash-cli/bash/bootstrap/cookie/cookie.json \
                - \
                - \
                $filename
        else
            local filename=$abcli_path_cookie/repo/$cookie_name.json
        fi

        abcli_log $filename
        cat $filename
        return
    fi

    if [ "$task" == "copy" ] ; then
        local cookie_name=$2
        local machine_kind=$(abcli_clarify_input $3 local)
        local machine_name=$4

        if [ "$machine_kind" == "local" ] ; then
            cp -v \
                $abcli_path_cookie/repo/$cookie_name.json \
                $abcli_path_cookie/cookie.json
        else
            # https://kb.iu.edu/d/agye
            abcli_scp \
                local \
                - \
                $abcli_path_cookie/repo/$cookie_name.json \
                $machine_kind \
                $machine_name \
                \~/git/awesome-bash-cli/bash/bootstrap/cookie/cookie.json
        fi

        return 
    fi

    if [ "$task" == "edit" ] ; then
        local machine_kind=$(abcli_clarify_input $2 local)
        local machine_name=$3

        if [ "$machine_kind" == "local" ] ; then
            nano $abcli_path_cookie/cookie.json
        else
            local filename="$abcli_object_path/scp-${machine_kind}-${machine_name}-cookie.json"

            abcli_scp \
                $machine_kind \
                $machine_name \
                \~/git/awesome-bash-cli/bash/bootstrap/cookie/cookie.json \
                - \
                - \
                $filename

            nano $filename

            abcli_scp \
                local \
                - \
                $filename \
                $machine_kind \
                $machine_name \
                \~/git/awesome-bash-cli/bash/bootstrap/cookie/cookie.json
        fi
        return
    fi

    if [ "$task" == "list" ] ; then
        ls -1 $abcli_path_bash/bootstrap/cookie/repo
        return
    fi

    if [ "$task" == "read" ] ; then
        python3 -m abcli.modules.cookie read \
            --keyword $2 \
            --default "$3" \
            ${@:4}
        return
    fi

    if [ "$task" == "write" ] ; then
        python3 -m abcli.modules.cookie write \
            --keyword $2 \
            --value "$3" \
            ${@:4}
        return
    fi

    abcli_log_error "-abcli: cookie: $task: command not found."
}
