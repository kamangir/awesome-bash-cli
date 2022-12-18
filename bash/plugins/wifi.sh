#! /usr/bin/env bash

function abcli_wifi_get_ssid() {
    if [ "$abcli_is_jetson" == true ] || [ "$abcli_is_rpi" == true ] ; then
        # https://code.luasoftware.com/tutorials/jetson-nano/jetson-nano-connect-to-wifi-via-command-line/
        # https://howchoo.com/pi/find-raspberry-pi-network-name-ssid
        local temp=$(iwgetid)
        python3 -c "print('$temp'.split('\"')[1])"
    elif [ "$abcli_is_mac" == true ] ; then
        # https://stackoverflow.com/a/4481019
        local temp=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
        python3 -c "print('$temp'.strip())"
    else
        echo "unknown"
    fi
}

export abcli_wifi_ssid=$(abcli_wifi_get_ssid)