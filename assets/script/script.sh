#! /usr/bin/env bash

abcli_object_name_current=$abcli_object_name
abcli_log "$abcli_object_name: started."

# --- your script here

abcli_log "Hello World!"

# /script

abcli_select $abcli_object_name_current
abcli_log "$abcli_object_name: completed."