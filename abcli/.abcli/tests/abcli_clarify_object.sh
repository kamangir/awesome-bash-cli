#! /usr/bin/env bash

function test_abcli_clarify_object_no_default() {
    local object_1=$(abcli_string_timestamp)
    local object_2=$(abcli_string_timestamp)
    local object_3=$(abcli_string_timestamp)

    local var

    abcli_select $object_3
    abcli_select $object_2
    abcli_select $object_1

    abcli_assert \
        $(abcli_clarify_object some-value) \
        some-value

    abcli_assert \
        $(abcli_clarify_object -) \
        non-empty

    var=""
    abcli_assert \
        $(abcli_clarify_object $var) \
        non-empty

    abcli_assert \
        $(abcli_clarify_object .) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object ..) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object ...) \
        $object_3
}

function test_abcli_clarify_object_some_default() {
    local object_1=$(abcli_string_timestamp)
    local object_2=$(abcli_string_timestamp)
    local object_3=$(abcli_string_timestamp)

    local var

    abcli_select $object_3
    abcli_select $object_2
    abcli_select $object_1

    abcli_assert \
        $(abcli_clarify_object some-value some-default) \
        some-value

    abcli_assert \
        $(abcli_clarify_object - some-default) \
        some-default

    var=""
    abcli_assert \
        $(abcli_clarify_object $var some-default) \
        some-default

    abcli_assert \
        $(abcli_clarify_object . some-default) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object .. some-default) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object ... some-default) \
        $object_3
}

function test_abcli_clarify_object_dot_default() {
    local object_1=$(abcli_string_timestamp)
    local object_2=$(abcli_string_timestamp)
    local object_3=$(abcli_string_timestamp)

    local var

    abcli_select $object_3
    abcli_select $object_2
    abcli_select $object_1

    abcli_assert \
        $(abcli_clarify_object some-value .) \
        some-value

    abcli_assert \
        $(abcli_clarify_object - .) \
        $object_1

    var=""
    abcli_assert \
        $(abcli_clarify_object $var .) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object . .) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object .. .) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object ... .) \
        $object_3
}

function test_abcli_clarify_object_dot_dot_default() {
    local object_1=$(abcli_string_timestamp)
    local object_2=$(abcli_string_timestamp)
    local object_3=$(abcli_string_timestamp)

    local var

    abcli_select $object_3
    abcli_select $object_2
    abcli_select $object_1

    abcli_assert \
        $(abcli_clarify_object some-value ..) \
        some-value

    abcli_assert \
        $(abcli_clarify_object - ..) \
        $object_2

    var=""
    abcli_assert \
        $(abcli_clarify_object $var ..) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object . ..) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object .. ..) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object ... ..) \
        $object_3
}

function test_abcli_clarify_object_dot_dot_dot_default() {
    local object_1=$(abcli_string_timestamp)
    local object_2=$(abcli_string_timestamp)
    local object_3=$(abcli_string_timestamp)

    local var

    abcli_select $object_3
    abcli_select $object_2
    abcli_select $object_1

    abcli_assert \
        $(abcli_clarify_object some-value ...) \
        some-value

    abcli_assert \
        $(abcli_clarify_object - ...) \
        $object_3

    var=""
    abcli_assert \
        $(abcli_clarify_object $var ...) \
        $object_3

    abcli_assert \
        $(abcli_clarify_object . ...) \
        $object_1

    abcli_assert \
        $(abcli_clarify_object .. ...) \
        $object_2

    abcli_assert \
        $(abcli_clarify_object ... ...) \
        $object_3
}
