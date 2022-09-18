#! /usr/bin/env bash

function abcli_browse_url() {
    if [ "$abcli_is_mac" == true ] ; then
        open "$1"
    elif [ "$abcli_is_ec2" == true ] ; then
        firefox "$1"
    elif [ "$abcli_is_rpi" == true ] ; then
        DISPLAY=:0 chromium-browser -kiosk --no-sandbox "$1"
    else
        abcli_log_error "-browse_url: failed: $1."
    fi 
}