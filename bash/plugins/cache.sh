#! /usr/bin/env bash

function cache() {
    abcli_cache $@
}

function abcli_cache() {
    local task=$(abcli_unpack_keyword $1 help)
    local keyword=$2

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli cache clone <object_1> <object_2>" \
            "clone cache from object_1 to object_2."
        abcli_help_line "abcli cache read <keyword>" \
            "read cache[keyword]."
        abcli_help_line "abcli cache search <keyword>" \
            "search in cache for keyword."
        abcli_help_line "abcli cache write <keyword> <value> [validate]" \
            "write cache[keyword]=value [and validate]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.cache --help
        fi
        return
    fi

    if [ "$task" == "clone" ] ; then
        python3 -m abcli.plugins.cache \
            clone \
            --source "$2" \
            --destination "$3" \
            ${@:4}
        return
    fi

    if [ "$task" == "read" ] ; then
        python3 -m abcli.plugins.cache \
            read \
            --keyword "$keyword" \
            ${@:3}
        return
    fi

    if [ "$task" == "search" ] ; then
        python3 -m abcli.plugins.cache \
            search \
            --keyword "$keyword" \
            ${@:3}
        return
    fi

    if [ "$task" == "write" ] ; then
        local options=$4
        local do_validate=$(abcli_option_int $options "validate" 0)

        python3 -m abcli.plugins.cache \
            write \
            --keyword "$keyword" \
            --value "$3" \
            ${@:5}

        if [ "$do_validate" == 1 ] ; then
            abcli_log "cache[$keyword] <- $(abcli_cache read $keyword)"
        fi

        return
    fi

    abcli_log_error "-abcli: cache: $task: command not found."
}