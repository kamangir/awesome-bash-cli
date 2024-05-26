#! /usr/bin/env bash

function test_abcli_list_in() {
    abcli_assert \
        $(abcli_list_in that this,that,which) \
        True

    abcli_assert \
        $(abcli_list_in who this,that,which) \
        False
}

function test_abcli_list_intersect() {
    abcli_assert_list \
        $(abcli_list_intersect this,that,who which,that,what,this) \
        this,that
}

function test_abcli_list_item() {
    abcli_assert \
        $(abcli_list_item this,that,who 1) \
        that
}

function test_abcli_list_len() {
    abcli_assert \
        $(abcli_list_len this,that,which) \
        3
}

function test_abcli_list_nonempty() {
    abcli_assert \
        $(abcli_list_nonempty this,,that) \
        this,that
}

function test_abcli_list_resize() {
    abcli_assert \
        $(abcli_list_resize this,that,which 2) \
        this,that
}

function test_abcli_list_sort() {
    abcli_assert \
        $(abcli_list_sort this,that) \
        that,this
}
