#! /usr/bin/env bash

function abcli_clone() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli clone$ABCUL<object_name>$ABCUL[~cache,~meta,~relations,~tags,~trail]$ABCUL[<suffix>]" \
            "clone $abcli_object_name[/suffix] -> object_name[/suffix]"
        return
    fi

    local options=$2
    local clone_meta=$(abcli_option_int "$options" meta 1)
    local clone_cache=$(abcli_option_int "$options" cache $clone_meta)
    local clone_relations=$(abcli_option_int "$options" relations $clone_meta)
    local clone_tags=$(abcli_option_int "$options" tags $clone_meta)

    abcli_download

    local object_path=$abcli_object_path
    local object_name=$abcli_object_name

    abcli_select $@

    local suffix="$3"
    if [ ! -z "$suffix" ] ; then
        mkdir -p ./$suffix
    fi

    rsync -arv "$object_path/$suffix" "./$suffix"

    if [ "$clone_cache" == 1 ] ; then
        abcli_cache clone $object_name $abcli_object_name
    fi

    if [ "$clone_relations" == 1 ] ; then
        abcli_relation clone $object_name $abcli_object_name
        abcli_relation set $abcli_object_name $object_name cloned
    fi

    if [ "$clone_tags" == 1 ] ; then
        abcli_tag clone $object_name $abcli_object_name
        abcli_tag set $abcli_object_name clone
    fi
}