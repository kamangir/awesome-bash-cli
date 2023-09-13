#! /usr/bin/env bash

function tag() {
    abcli_tag $@
}

function abcli_tag() {
    local task=$(abcli_unpack_keyword $1 help)
    local object=$(abcli_clarify_object $2 .)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli tag clone$ABCUL<object_1>$ABCUL<object_2>" \
            "clone object_1 tags -> object_2."
        abcli_show_usage "abcli tag get$ABCUL<object_name>" \
            "get object_name tags."
        abcli_show_usage "abcli tag search$ABCUL<tag>" \
            "search for all objects that are tagged tag."
        abcli_show_usage "abcli tag set$ABCUL<object_1,object_2>$ABCUL<tag_1,~tag_2>$ABCUL[validate]" \
            "add tag_1 and remove tag_2 from object_1 and object_2 [and validate]."
        abcli_show_usage "abcli tag set${ABCUL}disable|enable" \
            "disable|enable 'abcli tag set'."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.tags --help
        fi
        return
    fi

    if [ "$task" == "clone" ] ; then
        python3 -m abcli.plugins.tags \
            clone \
            --object $object \
            --object_2 $(abcli_clarify_object $3 .) \
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
        if [ "$object" == "disable" ] ; then
            export ABCLI_TAG_DISABLE=true
            return
        elif [ "$object" == "enable" ] ; then
            export ABCLI_TAG_DISABLE=false
            return
        elif [ "$ABCLI_TAG_DISABLE" == true ] ; then
            abcli_log_warning "ignored 'abcli tag set ${@:2}'."
            return
        fi

        local options=$4
        local do_validate=$(abcli_option_int "$options" validate 0)

        local object
        for object in $(echo "$object" | tr , " ") ; do
            python3 -m abcli.plugins.tags \
                set \
                --object $object \
                --tags $3 \
                ${@:5}

            if [ "$do_validate" == 1 ] ; then
                abcli_log "$object: $(abcli_tag get $object --log 0)"
            fi
        done

        return
    fi

    abcli_log_error "-abcli: tag: $task: command not found."
}