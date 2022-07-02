#! /usr/bin/env bash

function abcli_tag() {
    local task=$(abcli_unpack_keyword $1 help)
    local object=$(abcli_clarify_object "$2" $abcli_object_name)

    if [ "$task" == "help" ] ; then
        abcli_help_line "tag get object_1" \
            "get object_1 tags."
        abcli_help_line "tag search tag_1" \
            "search for all objects that are tagged tag_1."
        abcli_help_line "tag set object_1,object_2 this,~that [validate]" \
            "add this and remove that from object_1 and object_2 [and validate]."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.tags --help
        fi
        return
    fi

    if [ "$task" == "get" ] ; then
        python3 -m abcli.tags \
            get \
            --object "$object" \
            ${@:3}
        return
    fi

    if [ "$task" == "search" ] ; then
        python3 -m abcli.tags \
            search \
            --log 1 \
            --tags "$2" \
            ${@:3}
        return
    fi

    if [ "$task" == "set" ] ; then
        local object_list=$(echo "$object" | tr , " ")

        local options="$4"
        local do_validate=$(abcli_option_int "$options" "validate" 0)

        local object
        for object in $object_list ; do
            python3 -m abcli.tags \
                set \
                --object $object \
                --tags "$3" \
                ${@:5}

            if [ "$do_validate" == "1" ] ; then
                abcli_log "$object tags: $(abcli_tag get $object)"
            fi
        done

        return
    fi

    abcli_log_error "-abcli: tag: $task: command not found."
}
