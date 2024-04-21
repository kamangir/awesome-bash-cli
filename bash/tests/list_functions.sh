#! /usr/bin/env bash

function test_abcli_list_in() {
    abcli_assert \
        $(abcli_list_in that this,that,which) \
        True \
        abcli_list_in-True

    abcli_assert \
        $(abcli_list_in who this,that,which) \
        False \
        abcli_list_in-False
}

function test_abcli_list_intersect() {
    abcli_assert_list \
        $(abcli_list_intersect this,that,who which,that,what,this) \
        this,that \
        abcli_list_intersect
}

function test_abcli_list_item() {
    abcli_assert \
        $(abcli_list_item this,that,who 1) \
        that \
        abcli_list_item
}

function test_abcli_list_len() {
    abcli_assert \
        $(abcli_list_len this,that,which) \
        3 \
        test_abcli_list_len
}

function test_abcli_list_nonempty() {
    abcli_assert \
        $(abcli_list_nonempty this,,that) \
        this,that \
        abcli_list_nonempty
}

function test_abcli_list_resize() {
    abcli_assert \
        $(abcli_list_resize this,that,which 2) \
        this,that \
        test_abcli_list_resize
}

function test_abcli_list_sort() {
    abcli_assert \
        $(abcli_list_sort this,that) \
        that,this \
        abcli_list_sort
}
