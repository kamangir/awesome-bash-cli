#! /usr/bin/env bash

function abcli_instance() {
    local task=$(abcli_unpack_keyword $1 from_image)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli instance$ABCUL[from_image]$ABCUL[instance-type]$ABCUL[instance-name]$ABCUL[image=<image-name>]" \
            "create ec2 instance from <image-name>."
        abcli_show_usage "abcli instance from_template$ABCUL[template-name]$ABCUL[instance-type]$ABCUL[instance-name]$ABCUL[ssh|vnc]" \
            "create ec2 instance from <template-name>."
        abcli_show_usage "abcli instance get_ip$ABCUL<instance-name>" \
            "get <instance-name> ip address."
        abcli_show_usage "abcli instance list" \
            "list ec2 instances."
        abcli_show_usage "abcli instance terminate$ABCUL<instance-id>" \
            "terminate ec2 instance."

        printf "suggested instance_type(s): ${GREEN}p2.xlarge${NC} if gpu needed else ${GREEN}t2.xlarge${NC}.\n"

        abcli_log_list $abcli_instance_templates \
            --after "template(s)"

        abcli_log_list $abcli_aws_ec2_templates_list \
            --after "image(s)"

        return
    fi

    local sleep_seconds=20

    local extra_args=""

    if [ "$task" == "get_ip" ]; then
        local instance_name=$2

        local ec2_address=$(aws ec2 \
            describe-instances \
            --filter "Name=tag:Name,Values=$instance_name" \
            --query "Reservations[*].Instances[*].PublicDnsName" \
            --output text)

        echo $(python3 -c "print('-'.join('$ec2_address'.split('.')[0].split('-')[1:]))")
        return
    fi

    if [ "$task" == "from_image" ]; then
        local instance_type=$abcli_aws_ec2_default_instance_type
        local instance_type=$(abcli_clarify_input $2 $instance_type)

        local instance_name=$USER-$(abcli_string_timestamp)
        local instance_name=$(abcli_clarify_input $3 $instance_name)

        local options=$4
        local image_name=$(abcli_option "$options" image abcli)

        local var_name=abcli_aws_ec2_image_id_${image_name}
        local image_id=${!var_name}
        local security_group_ids=$abcli_aws_ec2_security_group_ids
        local subnet_id=$abcli_aws_ec2_subnet_id

        if [[ -z "$image_id" ]]; then
            abcli_log_error "-abcli: instance: $task: image_id not found."
            return 1
        fi
        if [[ -z "$security_group_ids" ]]; then
            abcli_log_error "-abcli: instance: $task: security_group_ids not found."
            return 1
        fi
        if [[ -z "$subnet_id" ]]; then
            abcli_log_error "-abcli: instance: $task: subnet_id not found."
            return 1
        fi

        abcli_log "abcli_instance: $task $instance_type -$image_id:$security_group_ids:$subnet_id-> $instance_name"

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

        local instance_ip_address=$(abcli_instance get_ip $instance_name)
        abcli_log "abcli: instance: created at $instance_ip_address"

        return
    fi

    if [ "$task" == "from_template" ]; then
        local template_name=$2
        if [ -z "$template_name" ] || [ "$template_name" == "-" ]; then
            local template_name=$abcli_aws_ec2_default_template
        fi

        local var_name=abcli_aws_ec2_templates_${template_name}
        local template_id=${!var_name}
        if [ -z "$template_id" ]; then
            abcli_log_error "-abcli: instance: $template_name: template not found."
            return
        fi

        local instance_type=$3
        if [ "$instance_type" == "-" ]; then
            local instance_type=""
        fi
        if [ ! -z "$instance_type" ]; then
            local extra_args="--instance-type $instance_type"
        fi

        local instance_name=$4
        if [ "$instance_name" == "-" ] || [ -z "$instance_name" ]; then
            local instance_name=$USER-$(abcli_string_timestamp)
        fi

        abcli_log "abcli_instance: $template_name($template_id) $instance_type -> $instance_name"

        # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html#launch-templates-as
        aws ec2 run-instances \
            --launch-template LaunchTemplateId=$template_id \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Owner,Value=$USER},{Key=Name,Value=$instance_name}]" \
            --region $(aws configure get region) \
            --count 1 \
            $extra_args >${abcli_path_git}/abcli_instance_log.txt

        local instance_ip_address=$(abcli_instance get_ip $instance_name)
        abcli_log "instance created at $instance_ip_address"
        if [ "$5" == "ssh" ]; then
            echo "instance is starting - waiting $sleep_seconds s ..."
            sleep $sleep_seconds
            abcli_ssh ec2 $instance_ip_address
        fi
        if [ "$5" == "vnc" ]; then
            echo "instance is starting - waiting $sleep_seconds s ..."
            sleep $sleep_seconds
            abcli_ssh ec2 $instance_ip_address vnc
        fi

        return
    fi

    if [ "$task" == "list" ]; then
        aws ec2 describe-instances \
            --query "Reservations[*].Instances[*].{Instance:InstanceId,PublicDens:PublicDnsName,Name:Tags[?Key=='Name']|[0].Value}" \
            --output text
        return
    fi

    if [ "$task" == "terminate" ]; then
        local host_name=$2
        if [ "$host_name" == "." ]; then
            local host_name=""
        fi
        if [ -z "$host_name" ]; then
            local host_name=$abcli_host_name
        fi

        # https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html
        aws ec2 \
            terminate-instances \
            --instance-ids $host_name
        return
    fi

    abcli_log_error "-abcli: instance: $task: command not found."
    return 1
}
