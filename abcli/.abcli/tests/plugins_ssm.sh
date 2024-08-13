#! /usr/bin/env bash

function test_abcli_plugins_ssm() {
    local secret_name="bashtest_secret-$(abcli_string_random)"
    local secret_value=$(abcli_string_random)

    abcli_ssm put $secret_name $secret_value
    sleep 1

    abcli_assert \
        $(abcli_ssm get $secret_name) \
        $secret_value

    abcli_ssm rm $secret_name
}
