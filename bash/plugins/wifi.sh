#! /usr/bin/env bash

#! /usr/bin/env bash

function abcli_wifi() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli wifi get_ssid" \
            "get wifi ssid."
        abcli_show_usage "abcli wifi copy_to_sd_card" \
            "copy wifi info to sd_card."
        return
    fi

    local function_name="abcli_wifi_$task"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name ${@:2}
        return
    fi

    if [ "$task" == "copy_to_sd_card" ]; then
        cp -v \
            $abcli_path_ignore/wpa_supplicant.conf \
            /Volumes/boot/
        return
    fi

    abcli_log_error "-abcli: wifi: $task: command not found."
    return 1
}

function abcli_wifi_get_ssid() {
    if [ "$abcli_is_jetson" == true ] || [ "$abcli_is_rpi" == true ]; then
        # https://code.luasoftware.com/tutorials/jetson-nano/jetson-nano-connect-to-wifi-via-command-line/
        # https://howchoo.com/pi/find-raspberry-pi-network-name-ssid
        local temp=$(iwgetid)
        python3 -c "print('$temp'.split('\"')[1])"
    elif [ "$abcli_is_mac" == true ]; then
        # https://stackoverflow.com/a/4481019
        local temp=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
        python3 -c "print('$temp'.strip())"
    else
        echo "unknown"
    fi
}

export abcli_wifi_ssid=$(abcli_wifi_get_ssid)
