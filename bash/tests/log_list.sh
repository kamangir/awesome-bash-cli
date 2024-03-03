#! /usr/bin/env bash

function test_abcli_log_list() {
    local options=$1
    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_upload=$(abcli_option_int "$options" upload 0)

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
