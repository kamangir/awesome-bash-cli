#! /usr/bin/env bash

function abcli_instance_get_ip() {
    local instance_name=$1

    local ec2_address=$(aws ec2 \
        describe-instances \
        --filter "Name=tag:Name,Values=$instance_name" \
        --query "Reservations[*].Instances[*].PublicDnsName" \
        --output text)

    python3 -c "print('-'.join('$ec2_address'.split('.')[0].split('-')[1:]))"
}
