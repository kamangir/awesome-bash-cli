#! /usr/bin/env bash

function abcli_browse_url() {
    local url=$1

    if [[ "$url" == "help" ]]; then
        abcli_show_usage "abcli browse_url <url>" \
            "browse <url>."
        return
    fi

    abcli_log "🔗 $url"
    if [ "$abcli_is_mac" == true ]; then
        open "$url"
    elif [ "$abcli_is_ec2" == true ]; then
        firefox "$url"
    elif [ "$abcli_is_rpi" == true ]; then
        DISPLAY=:0 chromium-browser -kiosk --no-sandbox "$url"
    else
        abcli_log_error "-abcli: browse_url: $url: failed."
    fi
}
