#! /usr/bin/env bash

function tag() {
    abcli_tag $@
}

function abcli_tag() {
    local task=$(abcli_unpack_keyword $1 help)
    local object=$(abcli_clarify_object "$2" $abcli_object_name)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name tag clone <object_1> <object_2>" \
            "clone object_1 tags -> object_2."
        abcli_help_line "$abcli_cli_name tag get <object_name>" \
            "get object_name tags."
        abcli_help_line "$abcli_cli_name tag search <tag>" \
            "search for all objects that are tagged tag."
        abcli_help_line "$abcli_cli_name tag set <object_1,object_2> <tag_1,~tag_2> [validate]" \
            "add tag_1 and remove tag_2 from object_1 and object_2 [and validate]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.tags --help
        fi
        return
    fi

    if [ "$task" == "clone" ] ; then
        python3 -m abcli.plugins.tags \
            clone \
            --object $object \
            --object_2 $(abcli_clarify_object "$3" $abcli_object_name) \
            ${@:4}
        return
    fi

    if [ "$task" == "get" ] ; then
        python3 -m abcli.plugins.tags \
            get \
            --item_name tag \
            --object $object \
            ${@:3}
        return
    fi

    if [ "$task" == "search" ] ; then
        python3 -m abcli.plugins.tags \
            search \
            --tags $2 \
            ${@:3}
        return
    fi

    if [ "$task" == "set" ] ; then
        local options=$4
        local do_validate=$(abcli_option_int "$options" "validate" 0)

        local object
        for object in $(echo "$object" | tr , " ") ; do
            python3 -m abcli.plugins.tags \
                set \
                --object $object \
                --tags $3 \
                ${@:5}

            if [ "$do_validate" == "1" ] ; then
                abcli_log "$object tags: $(abcli_tag get $object)"
            fi
        done

        return
    fi

    abcli_log_error "-abcli: tag: $task: command not found."
}

python3 -m abcli.plugins.tags create