#! /usr/bin/env bash

function cache() {
    abcli_cache $@
}

function abcli_cache() {
    local task=$(abcli_unpack_keyword $1 help)
    local keyword=$2

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli cache clone$ABCUL<object-1> <object-2>" \
            "clone cache from <object-1> to <object-2>."
        abcli_show_usage "abcli cache read$ABCUL<keyword>" \
            "read cache[<keyword>]."
        abcli_show_usage "abcli cache search$ABCUL<keyword>" \
            "search in cache for <keyword>."
        abcli_show_usage "abcli cache write$ABCUL<keyword> <value>$ABCUL[validate]" \
            "write cache[<keyword>]=value."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.plugins.cache --help
        fi
        return
    fi

    if [ "$task" == "clone" ]; then
        python3 -m abcli.plugins.cache \
            clone \
            --source "$2" \
            --destination "$3" \
            ${@:4}
        return
    fi

    if [ "$task" == "read" ]; then
        python3 -m abcli.plugins.cache \
            read \
            --keyword "$keyword" \
            ${@:3}
        return
    fi

    if [ "$task" == "search" ]; then
        python3 -m abcli.plugins.cache \
            search \
            --keyword "$keyword" \
            ${@:3}
        return
    fi

    if [ "$task" == "write" ]; then
        local options=$4
        local do_validate=$(abcli_option_int "$options" "validate" 0)

        python3 -m abcli.plugins.cache \
            write \
            --keyword "$keyword" \
            --value "$3" \
            ${@:5}

        if [ "$do_validate" == 1 ]; then
            abcli_log "cache[$keyword] <- $(abcli_cache read $keyword)"
        fi

        return
    fi

    abcli_log_error "-abcli: cache: $task: command not found."
    return 1
}
