#! /usr/bin/env bash

function abcli_file_size() {
    echo $(python3 -c "from abcli import file, string; print(string.pretty_bytes(file.size('$1')));")
}