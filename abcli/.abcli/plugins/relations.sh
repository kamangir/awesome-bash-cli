#! /usr/bin/env bash

function relation() {
    abcli_relation $@
}

function abcli_relation() {
    local task=$(abcli_unpack_keyword $1 help)
    local object_1=$(abcli_clarify_object $2 .)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli relation clone <object_1> <object_2>" \
            "clone object_1 relation -> object_2."
        abcli_show_usage "abcli relation get <object_1> <object_2>" \
            "get relation between object_1 and object_2."
        abcli_show_usage "abcli relation list" \
            "list possible relations."
        abcli_show_usage "abcli relation search <object-name> [--relation <relation>]" \
            "search for all relations of/relation to <object-name>."
        abcli_show_usage "abcli relation set <object_1> <object_2> <relation> [validate]" \
            "set object_1 =relation=> object_2 [and validate]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.plugins.relations --help
            python3 -m abcli.plugins.relations list
        fi
        return
    fi

    if [ "$task" == "clone" ] || [ "$task" == "get" ] || [ "$task" == "set" ]; then
        local object_2=$(abcli_clarify_object $3 .)
    fi

    if [ "$task" == "clone" ]; then
        python3 -m abcli.plugins.relations \
            clone \
            --object_1 $object_1 \
            --object_2 $object_2 \
            ${@:4}
        return
    fi

    if [ "$task" == "get" ]; then
        python3 -m abcli.plugins.relations \
            get \
            --object_1 $object_1 \
            --object_2 $object_2 \
            ${@:4}
        return
    fi

    if [ "$task" == "list" ]; then
        python3 -m abcli.plugins.relations \
            list \
            ${@:2}
        return
    fi

    if [ "$task" == "search" ]; then
        python3 -m abcli.plugins.relations \
            search \
            --object_1 $object_1 \
            ${@:3}
        return
    fi

    if [ "$task" == "set" ]; then
        local options=$5
        local do_validate=$(abcli_option_int "$options" validate 0)

        python3 -m abcli.plugins.relations \
            set \
            --object_1 $object_1 \
            --object_2 $object_2 \
            --relation $4 \
            ${@:6}

        if [ "$do_validate" == 1 ]; then
            abcli_log "relation: $object_1 -$(abcli_relation get $object_1 $object_2)-> $object_2"
        fi

        return
    fi

    abcli_log_error "-abcli: relation: $task: command not found."
    return 1
}
