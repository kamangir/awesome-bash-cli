#! /usr/bin/env bash

function test_abcli_cat() {
    local object_name=$ABCLI_TEST_OBJECT

    abcli_download - $object_name

    local object_path=$ABCLI_OBJECT_ROOT/$object_name

    abcli_cat $object_path/vancouver.json
}

function test_abcli_hr() {
    abcli_hr
}

function test_abcli_log_local() {
    abcli_log_local "testing"
}

function test_abcli_show_usage() {
    abcli_show_usage "command-line" \
        "usage"
}
