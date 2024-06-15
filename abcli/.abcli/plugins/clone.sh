#! /usr/bin/env bash

function abcli_copy() {
    abcli_clone "$@"
}

function abcli_cp() {
    abcli_clone "$@"
}

function abcli_clone() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        local options="~cache,cp,~download,~meta,~relations,~tags,${EOPE}upload"
        abcli_show_usage "@cp$EOP|@copy|@clone$ABCUL..|<object-1> .|<object-2>$ABCUL$options" \
            "copy <object-1> -> <object-2>."
        return
    fi

    local object_1_name=$(abcli_clarify_object $1 ..)
    local object_2_name=$(abcli_clarify_object $2 .)

    local options=$3
    local clone_meta=$(abcli_option_int "$options" meta 1)
    local clone_cache=$(abcli_option_int "$options" cache $clone_meta)
    local clone_relations=$(abcli_option_int "$options" relations $clone_meta)
    local clone_tags=$(abcli_option_int "$options" tags $clone_meta)
    local do_download=$(abcli_option_int "$options" download 1)
    local do_upload=$(abcli_option_int "$options" upload 0)
    local transfer_mechanism=$(abcli_option_choice "$options" cp,mv mv)

    abcli_log "$object_1_name -$transfer_mechanism-> $object_2_name"

    [[ "$do_download" == 1 ]] &&
        abcli_download - $object_1_name

    local object_1_path=$abcli_object_root/$object_1_name
    local object_2_path=$abcli_object_root/$object_2_name

    abcli_eval - \
        rsync -arv \
        $object_1_path/ \
        $object_2_path

    [[ "$clone_cache" == 1 ]] &&
        abcli_cache clone $object_1_name $object_2_name

    if [ "$clone_relations" == 1 ]; then
        abcli_relation clone $object_1_name $object_2_name
        abcli_relation set $object_1_name $object_2_name cloned
    fi

    if [ "$clone_tags" == 1 ]; then
        abcli_tag clone $object_1_name $object_2_name
        abcli_tag set $object_2_name clone
    fi

    pushd $object_2_path >/dev/null
    local filename
    for filename in $object_1_name.*; do
        $transfer_mechanism -v \
            $filename \
            $object_2_path/$object_2_name.${filename##*.}
    done
    popd >/dev/null

    [[ "$do_upload" == 1 ]] &&
        abcli_upload - $object_2_name

    return 0
}
