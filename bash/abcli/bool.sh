#! /usr/bin/env bash

function abcli_not() {
    if [ "$1" == 1 ] ; then
        echo 0
    else
        echo 1
    fi
}