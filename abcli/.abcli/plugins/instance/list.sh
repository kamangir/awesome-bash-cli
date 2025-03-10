#! /usr/bin/env bash

function abcli_instance_list() {
    local options=$1
    local list_images=$(abcli_option_int "$options" images 0)
    local list_templates=$(abcli_option_int "$options" templates 0)

    if [[ "$list_images" == 1 ]]; then
        abcli_log_list $abcli_aws_ec2_image_list \
            --after "image(s)"
    elif [[ "$list_templates" == 1 ]]; then
        abcli_log_list $abcli_aws_ec2_templates_list \
            --after "template(s)"
    else
        aws ec2 describe-instances \
            --query "Reservations[*].Instances[*].{Instance:InstanceId,PublicDens:PublicDnsName,Name:Tags[?Key=='Name']|[0].Value}" \
            --output text
    fi
}
