#! /usr/bin/env bash

function abcli_instance_from_image() {
    local instance_type=$(abcli_clarify_input $1 $abcli_aws_ec2_default_instance_type)

    local instance_name=$(abcli_clarify_input $2 $USER-$(abcli_string_timestamp_short))

    local options=$3
    local image_name=$(abcli_option "$options" image abcli)

    local var_name=abcli_aws_ec2_image_id_${image_name}
    local image_id=${!var_name}
    local security_group_ids=$abcli_aws_ec2_security_group_ids
    local subnet_id=$abcli_aws_ec2_subnet_id
    if [[ -z "$image_id" ]]; then
        abcli_log_error "$image_name: image_id not found."
        return 1
    fi
    if [[ -z "$security_group_ids" ]]; then
        abcli_log_error "$image_name: security_group_ids not found."
        return 1
    fi
    if [[ -z "$subnet_id" ]]; then
        abcli_log_error "$image_name: subnet_id not found."
        return 1
    fi

    abcli_log "@instance: from image: $image_name($image_id) $instance_type -$security_group_ids:$subnet_id-> $instance_name"

    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html#launch-templates-as
    aws ec2 run-instances \
        --image-id "$image_id" \
        --key-name bolt \
        --security-group-ids $security_group_ids \
        --subnet-id "$subnet_id" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Owner,Value=$USER},{Key=Name,Value=$instance_name}]" \
        --region $(aws configure get region) \
        --count 1 \
        --instance-type "$instance_type" >$abcli_path_git/abcli_instance_log.txt
    [[ $? -ne 0 ]] && return 1

    abcli_instance_from_xxx_finish $instance_name $3
}
