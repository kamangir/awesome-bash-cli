#! /usr/bin/env bash

function abcli_not() {
    if [ "$1" == 1 ] || [ "$1" == true ] ; then
        echo 0
    else
        echo 1
    fi
}