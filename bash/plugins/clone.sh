#! /usr/bin/env bash

function abcli_clone() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli clone <object_name> [~cache,~meta,~relations,~tags,~trail] [<postfix>]" \
            "clone $abcli_object_name[/postfix] -> object_name[/postfix]"
        return
    fi

    local options=$2
    local clone_meta=$(abcli_option_int "$options" "meta" 1)
    local clone_cache=$(abcli_option_int "$options" "cache" $clone_meta)
    local clone_relations=$(abcli_option_int "$options" "relations" $clone_meta)
    local clone_tags=$(abcli_option_int "$options" "tags" $clone_meta)

    abcli_download

    local object_path=$abcli_object_path
    local object_name=$abcli_object_name

    abcli_select $@

    local postfix="$3"
    if [ ! -z "$postfix" ] ; then
        mkdir -p ./$postfix
    fi

    rsync -arv "$object_path/$postfix" "./$postfix"

    if [ "$clone_cache" == "1" ] ; then
        abcli_cache clone $object_name $abcli_object_name
    fi

    if [ "$clone_relations" == "1" ] ; then
        abcli_relation clone $object_name $abcli_object_name
        abcli_relation set $abcli_object_name $object_name cloned
    fi

    if [ "$clone_tags" == "1" ] ; then
        abcli_tag clone $object_name $abcli_object_name
        abcli_tag set $abcli_object_name clone
    fi
}