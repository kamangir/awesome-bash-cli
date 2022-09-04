#! /usr/bin/env bash

function abcli_cookie() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli cookie cat [template]" \
            "cat cookie [template]."
        abcli_help_line "abcli cp <sample>" \
            "cp <sample> cookie."
        abcli_help_line "abcli cookie edit" \
            "edit cookie."
        abcli_help_line "abcli cookie list" \
            "list sample cookies."
        abcli_help_line "abcli cookie read <keyword> [<default>]" \
            "read <keyword> from cookie."
        abcli_help_line "abcli cookie write <keyword> <value>" \
            "write <keyword> = <value> in cookie."

        return
    fi

    if [ "$task" == "cat" ] ; then
        local options="$2"
        local show_template=$(abcli_option_int "$options" "template" 0)

        if [ "$show_template" == "1" ] ; then
            local filename=$abcli_path_cookie/cookie.template.json
        else
            local filename=$abcli_path_cookie/cookie.json
        fi

        abcli_log $filename
        cat $filename
        return
    fi

    if [ "$task" == "cp" ] ; then
        local cookie_name=$2
        cp -v \
            $abcli_path_bash/bootstrap/sample-cookie/$cookie_name.json \
            $abcli_path_cookie/cookie.json
        return
    fi

    if [ "$task" == "edit" ] ; then
        nano $abcli_path_cookie/cookie.json
        return
    fi

    if [ "$task" == "list" ] ; then
        ls -1 $abcli_path_bash/bootstrap/sample-cookie
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
