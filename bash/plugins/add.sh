#! /usr/bin/env bash

function abcli_add() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli add <object_1,object_2> [~meta,~relations,~tags]" \
            "$abcli_object_name += <object_1> + <object_2>"
        return
    fi

    local object_name_list=$1
    local count=$(abcli_list_len "$object_name_list" --delim ,)
    abcli_log "$abcli_object_name += $count object(s) : [$object_name_list]"

    local options="$2"
    local clone_meta=$(abcli_option_int "$options" "meta" 1)
    local clone_relations=$(abcli_option_int "$options" "relations" $clone_meta)
    local clone_tags=$(abcli_option_int "$options" "tags" $clone_meta)

    local abcli_object_name_current=$abcli_object_name
    local abcli_object_path_current=$abcli_object_path

    local object_name
    for object_name in $(echo "$object_name_list" | tr , " ") ; do
        abcli_log "$abcli_object_name_current += $object_name"

        abcli_select $object_name ~trail
        abcli_download

        python3 -m abcli.modules.objects \
            add \
            --object_path_1 $abcli_object_path_current/ \
            --object_path_2 $abcli_object_path

        if [ "$clone_tags" == 1 ] ; then
            abcli_tag set $abcli_object_name_current "$(abcli_tag get $object_name),add"
        fi

        if [ "$clone_relations" == 1 ] ; then
            abcli_relation set $abcli_object_name_current $object_name contains
        fi
    done

    abcli_select $abcli_object_name_current ~trail
}