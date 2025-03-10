#! /usr/bin/env bash

function abcli_instance_terminate() {
    local host_name=$1
    [[ "$host_name" == "." ]] || [[ -z "$host_name" ]] &&
        host_name=$abcli_host_name

    # https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html
    abcli_eval - \
        aws ec2 \
        terminate-instances \
        --instance-ids $host_name
}
