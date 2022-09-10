#! /usr/bin/env bash

function abcli_sleep() {
    local length=$1

    abcli_log_local "pausing for $length ... (Ctrl+C to stop)"
    sleep $length
}