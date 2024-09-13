#! /usr/bin/env bash

function abcli_string_after() {
    abcli_assert \
        $(abcli_string_after \
            "this-is-a-test" \
            "") \
        ""
    abcli_assert \
        $(abcli_string_after \
            "this-is-a-test" \
            "was") \
        ""

    abcli_assert \
        $(abcli_string_after \
            "this-is-a-test" \
            "is") \
        "-is-a-test"

    abcli_assert \
        $(abcli_string_after \
            "this-is-a-test-that-is-very-important" \
            "is") \
        "-is-a-test-that-is-very-important"

    abcli_assert \
        $(abcli_string_after \
            "this-is-a-test-that-is-very-important-and-now-is-running" \
            "is") \
        "-is-a-test-that-is-very-important-and-now-is-running"
}

function abcli_string_before() {
    abcli_assert \
        $(abcli_string_before \
            "this-is-a-test" \
            "") \
        ""
    abcli_assert \
        $(abcli_string_before \
            "this-is-a-test" \
            "was") \
        ""

    abcli_assert \
        $(abcli_string_before \
            "this-is-a-test" \
            "is") \
        "th"

    abcli_assert \
        $(abcli_string_before \
            "this-is-a-test-that-is-very-important" \
            "is") \
        "th"

    abcli_assert \
        $(abcli_string_before \
            "this-is-a-test-that-is-very-important-and-now-is-running" \
            "is") \
        "th"
}

function test_abcli_string_random() {
    abcli_assert \
        $(abcli_string_random) \
        - non-empty
}

function test_abcli_string_timestamp() {
    abcli_assert \
        $(abcli_string_timestamp) \
        - non-empty
}

function test_abcli_string_timestamp_short() {
    abcli_assert \
        $(abcli_string_timestamp_short) \
        - non-empty
}

function test_abcli_string_today() {
    abcli_assert \
        $(abcli_string_today) \
        - non-empty
}
