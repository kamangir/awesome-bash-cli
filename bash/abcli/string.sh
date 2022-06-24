#! /usr/bin/env bash

function abcli_string_after() {
    echo $(python3 -c "from abcli import string; print(string.after('$1','$2'));")
}

function abcli_string_before() {
    echo $(python3 -c "from abcli import string; print(string.before('$1','$2'));")
}

function abcli_string_pretty_date() {
    echo $(python3 -c "from abcli import string; print(string.pretty_date('zone'));")
}

function abcli_string_timestamp() {
    echo $(python3 -c "from abcli import string; print(string.pretty_date('filename,unique'));")
}

function abcli_string_today() {
    echo $(python3 -c "from abcli import string; print(string.pretty_date('filename,~time'));")
}