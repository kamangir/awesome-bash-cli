#! /usr/bin/env bash

function test_abcli_options() {
    local options=$1

    options="a,~b,c=1,d=0,var_e,-f,g=2,h=that"

    abcli_assert $(abcli_option "$options" a) True
    abcli_assert $(abcli_option "$options" a default) True

    abcli_assert $(abcli_option "$options" b) False
    abcli_assert $(abcli_option "$options" b default) False

    abcli_assert $(abcli_option "$options" c) 1
    abcli_assert $(abcli_option "$options" c default) 1

    abcli_assert $(abcli_option "$options" d) 0
    abcli_assert $(abcli_option "$options" d default) 0

    abcli_assert $(abcli_option "$options" var_e) True
    abcli_assert $(abcli_option "$options" var_e default) True

    abcli_assert $(abcli_option "$options" f) False
    abcli_assert $(abcli_option "$options" f default) False

    abcli_assert $(abcli_option "$options" g) 2
    abcli_assert $(abcli_option "$options" g default) 2

    abcli_assert $(abcli_option "$options" h) that
    abcli_assert $(abcli_option "$options" h default) that

    abcli_assert $(abcli_option "$options" other) ""
    abcli_assert $(abcli_option "$options" other default) default
}

function test_abcli_options_choice() {
    local options=$1

    abcli_assert \
        $(abcli_option_choice \
            "x=1,~y,separated,z=12" comma,separated,list default) separated
    abcli_assert \
        $(abcli_option_choice \
            "x=1,~y,separated,z=12" comma,separated,list) separated

    abcli_assert \
        $(abcli_option_choice \
            "x=1,~y,attached,z=12" comma,separated,list default) default
    abcli_assert \
        $(abcli_option_choice \
            "x=1,~y,attached,z=12" comma,separated,list) ""
}

function test_abcli_options_int() {
    local options=$1

    options="a,~b,c=1,d=0,var_e,-f"

    abcli_assert $(abcli_option_int "$options" a) 1
    abcli_assert $(abcli_option_int "$options" a 0) 1
    abcli_assert $(abcli_option_int "$options" a 1) 1

    abcli_assert $(abcli_option_int "$options" b) 0
    abcli_assert $(abcli_option_int "$options" b 0) 0
    abcli_assert $(abcli_option_int "$options" b 1) 0

    abcli_assert $(abcli_option_int "$options" c) 1
    abcli_assert $(abcli_option_int "$options" c 0) 1
    abcli_assert $(abcli_option_int "$options" c 1) 1

    abcli_assert $(abcli_option_int "$options" d) 0
    abcli_assert $(abcli_option_int "$options" d 0) 0
    abcli_assert $(abcli_option_int "$options" d 1) 0

    abcli_assert $(abcli_option_int "$options" var_e) 1
    abcli_assert $(abcli_option_int "$options" var_e 0) 1
    abcli_assert $(abcli_option_int "$options" var_e 1) 1

    abcli_assert $(abcli_option_int "$options" f) 0
    abcli_assert $(abcli_option_int "$options" f 0) 0
    abcli_assert $(abcli_option_int "$options" f 1) 0

    abcli_assert $(abcli_option_int "$options" g) 0
    abcli_assert $(abcli_option_int "$options" g 0) 0
    abcli_assert $(abcli_option_int "$options" g 1) 1
}

function test_abcli_options_subset() {
    abcli_assert \
        $(abcli_option_subset \
            "x=3,z=4" \
            "x=1,y=2") \
        "x=3,y=2"
}
