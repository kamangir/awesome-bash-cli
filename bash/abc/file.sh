#! /usr/bin/env bash

function abc_file_size() {
    echo $(python3 -c "from abc import file, string; print(string.pretty_bytes(file.size('$1')));")
}