#! /usr/bin/env bash

function abcli_clarify_object() {
    local object_name=$1
    local default=$2

    if [ -z "$object_name" ] || [ "$object_name" == "-" ] ; then
        local object_name=$default
    fi
    if [ "$object_name" == "." ] ; then
        local object_name=$abcli_object_name
    fi
    if [ "$object_name" == ".." ] ; then
        local object_name=$abcli_object_name_prev
    fi
    if [ "$(abcli_keyword_is $object_name validate)" == true ] ; then
        local object_name="validate"
    fi

    echo $object_name
}