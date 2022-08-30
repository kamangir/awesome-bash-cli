#! /usr/bin/env bash

function abcli_cookie() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli cookie cat" \
            "cat cookie."
        abcli_help_line "abcli cookie edit" \
            "edit cookie."
        abcli_help_line "abcli cookie read <object-name>" \
            "read <object-name> from cookie."
        abcli_help_line "abcli cookie write <object-name> <value>" \
            "write <object-name> = <value> in cookie."

        return
    fi

    if [ "$task" == "cat" ] ; then
        cat $abcli_path_cookie/cookie.json
        return
    fi

    if [ "$task" == "edit" ] ; then
        nano $abcli_path_cookie/cookie.json
        return
    fi

    if [ "$task" == "read" ] ; then
        local object_name=$2

        python3 -c "from abcli import file; print(file.load_json('$abcli_path_cookie/cookie.json',civilized=True)[1]$object_name)"
        return
    fi


    if [ "$task" == "write" ] ; then
        local object_name=$2
        local value=$3

        python3 -c "from abcli import file; cookie=file.load_json('$abcli_path_cookie/cookie.json',civilized=True)[1]; cookie$object_name=$value; file.save_json('$abcli_path_cookie/cookie.json',cookie)"
        return
    fi

    abcli_log_error "-abcli: cookie: $task: command not found."
}
