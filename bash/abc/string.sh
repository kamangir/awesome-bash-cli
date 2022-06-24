#! /usr/bin/env bash

function abc_string_after() {
    echo $(python3 -c "from abc import string; print(string.after('$1','$2'));")
}

function abc_string_before() {
    echo $(python3 -c "from abc import string; print(string.before('$1','$2'));")
}

function abc_string_pretty_date() {
    echo $(python3 -c "from abc import string; print(string.pretty_date('zone'));")
}

function abc_string_timestamp() {
    echo $(python3 -c "from abc import string; print(string.pretty_date('filename,unique'));")
}

function abc_string_today() {
    echo $(python3 -c "from abc import string; print(string.pretty_date('filename,~time'));")
}