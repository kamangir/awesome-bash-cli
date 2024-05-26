#! /usr/bin/env bash

function test_abcli_log_list() {
    abcli_log_list this+that \
        --before "list of" \
        --delim + \
        --after "important thing(s)"

    abcli_log_list "this that" \
        --before "list of" \
        --delim space \
        --after "important thing(s)"

    abcli_log_list "this,that" \
        --before "list of" \
        --delim , \
        --after "important thing(s)"

    abcli_log_list this,that
}
