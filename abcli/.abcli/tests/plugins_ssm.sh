#! /usr/bin/env bash

function test_abcli_plugins_ssm() {
    local name="bashtest_secret"
    local value=$(abcli_string_random)

    abcli_ssm put $name $value
    sleep 0.1

    abcli_assert \
        $(abcli_ssm get $name) \
        $value
}
