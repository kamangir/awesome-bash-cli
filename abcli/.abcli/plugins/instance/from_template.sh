#! /usr/bin/env bash

function abcli_instance_from_template() {
    local template_name=$(abcli_clarify_input $1 $abcli_aws_ec2_default_template)

    local var_name=abcli_aws_ec2_templates_${template_name}
    local template_id=${!var_name}
    if [ -z "$template_id" ]; then
        abcli_log_error "$template_name: template-id not found."
        return 1
    fi

    local instance_type=$(abcli_clarify_input $2)
    local extra_args=""
    [[ ! -z "$instance_type" ]] &&
        extra_args="--instance-type $instance_type"

    local instance_name=$(abcli_clarify_input $3 $USER-$(abcli_string_timestamp_short))

    abcli_log "@instance: from template: $template_name($template_id) $instance_type -> $instance_name"

    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html#launch-templates-as
    aws ec2 run-instances \
        --launch-template LaunchTemplateId=$template_id \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Owner,Value=$USER},{Key=Name,Value=$instance_name}]" \
        --region $(aws configure get region) \
        --count 1 \
        $extra_args >$abcli_path_git/abcli_instance_log.txt
    [[ $? -ne 0 ]] && return 1

    abcli_instance_from_xxx_finish $instance_name $4
}

function abcli_instance_from_xxx_finish() {
    local instance_name=$1

    abcli_sleep seconds=5
    local instance_ip_address=$(abcli_instance get_ip $instance_name)
    abcli_log "@instance: created at $instance_ip_address"

    local options=$2
    local do_ssh=$(abcli_option_int "$options" ssh 0)
    local do_vnc=$(abcli_option_int "$options" vnc 0)

    [[ "$do_ssh" == 1 ]] || [[ "$do_vnc" == 1 ]] &&
        abcli_sleep seconds=20

    if [[ "$do_ssh" == 1 ]]; then
        abcli_ssh ec2 $instance_ip_address
    elif [[ "$do_vnc" == 1 ]]; then
        abcli_ssh ec2 $instance_ip_address vnc
    fi
}
