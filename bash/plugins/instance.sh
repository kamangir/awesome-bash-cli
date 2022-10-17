#! /usr/bin/env bash

function abcli_instance() {
    local task=$(abcli_unpack_keyword $1 from_image)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli instance [from_image] [-/instance_type] [-/instance_name] [image=<abcli>|<abcli-gpu>,ssh,vnc]" \
            "create ec2 instance from image."
        abcli_show_usage "abcli instance describe instance_name" \
            "describe ec2 instance instance_name."
        abcli_show_usage "abcli instance from_template [-/template_name] [-/instance_type] [-/instance_name] [ssh/vnc]" \
            "create ec2 instance from template."
        abcli_show_usage "abcli instance list" \
            "list ec2 instances."
        abcli_show_usage "instance terminate instance_id" \
            "terminate ec2 instance."

        printf "suggested instance_type(s): ${GREEN}p2.xlarge${NC} if gpu needed else ${GREEN}t2.xlarge${NC}.\n"

        local templates=$(python3 -c "from abcli.plugins import aws; print(','.join(aws.get_from_json('ec2',{}).get('templates',{}).keys()))")
        abcli_log_list $templates , "ec2 template(s)"

        return
    fi

    local sleep_seconds=20

    local extra_args=""

    if [ "$task" == "describe" ] ; then
        local instance_name=$2

        local ec2_address=$(aws ec2 \
            describe-instances \
            --filter "Name=tag:Name,Values=$instance_name" \
            --query "Reservations[*].Instances[*].PublicDnsName" \
            --output text)

        echo $(python3 -c "print('-'.join('$ec2_address'.split('.')[0].split('-')[1:]))")
        return
    fi

    if [ "$task" == "from_image" ] ; then
        local instance_type=$(abcli_aws_json_get "['ec2']['default_instance_type']")
        local instance_type=$(abcli_clarify_input $2 $instance_type)

        local instance_name=$USER-$(abcli_string_timestamp)
        local instance_name=$(abcli_clarify_input $3 $instance_name)

        local options=$4
        local do_ssh=$(abcli_option_int "$options" ssh 0)
        local do_vnc=$(abcli_option_int "$options" vnc 0)
        local image_name=$(abcli_option "$options" image abcli)

        local image_id=$(abcli_aws_json_get "['ec2']['image_id']['$image_name']")
        local security_group_ids=$(abcli_aws_json_get "['ec2']['security_group_ids']")
        local subnet_id=$(abcli_aws_json_get "['ec2']['subnet_id']")

        abcli_log "abcli_instance: $task $instance_type -$image_id:$security_group_ids:$subnet_id-> $instance_name"

        # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html#launch-templates-as
        aws ec2 run-instances \
            --image-id $image_id \
            --key-name bolt \
            --security-group-ids $security_group_ids \
            --subnet-id $subnet_id \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Owner,Value=$USER},{Key=Name,Value=$instance_name}]" \
            --region $(aws configure get region) \
            --count 1 \
            --instance-type $instance_type > $abcli_path_git/abcli_instance_log.txt

        local instance_ip_address=$(abcli_instance describe $instance_name)
        abcli_log "abcli: instance: created at $instance_ip_address"

        if [ "$do_ssh" == 1 ] || [ "$do_vnc" == 1 ] ; then
            abcli_sleep $sleep_seconds

            if [ "$do_vnc" == 1 ] ; then
                abcli_ssh ec2 $instance_ip_address vnc
            else
                abcli_ssh ec2 $instance_ip_address
            fi
        fi

        return
    fi

    if [ "$task" == "from_template" ] ; then
        local template_name=$2
        if [ -z "$template_name" ] || [ "$template_name" == "-" ] ; then
            local template_name=$(abcli_aws_json_get "['ec2']['default_template']")
        fi

        local template_id=$(abcli_aws_json_get "['ec2']['templates'].get('$template_name','')")
        if [ -z "$template_id" ] ; then
            abcli_log_error "-abcli: instance: $template_name: template not found."
            return
        fi

        local instance_type=$3
        if [ "$instance_type" == "-" ] ; then
            local instance_type=""
        fi
        if [ ! -z "$instance_type" ] ; then
            local extra_args="--instance-type $instance_type"
        fi

        local instance_name=$4
        if [ "$instance_name" == "-" ] || [ -z "$instance_name" ] ; then
            local instance_name=$USER-$(abcli_string_timestamp)
        fi

        abcli_log "abcli_instance: $template_name($template_id) $instance_type -> $instance_name"

        # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html#launch-templates-as
        aws ec2 run-instances \
            --launch-template LaunchTemplateId=$template_id \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Owner,Value=$USER},{Key=Name,Value=$instance_name}]" \
            --region $(aws configure get region) \
            --count 1 \
            $extra_args > ${abcli_path_git}/abcli_instance_log.txt
            
        local instance_ip_address=$(abcli_instance describe $instance_name)
        abcli_log "instance created at $instance_ip_address"
        if [ "$5" == "ssh" ] ; then
            echo "instance is starting - waiting $sleep_seconds s ..."
            sleep $sleep_seconds
            abcli_ssh ec2 $instance_ip_address
        fi
        if [ "$5" == "vnc" ] ; then
            echo "instance is starting - waiting $sleep_seconds s ..."
            sleep $sleep_seconds
            abcli_ssh ec2 $instance_ip_address vnc
        fi

        return
    fi

    if [ "$task" == "list" ] ; then
        aws ec2 describe-instances \
            --query "Reservations[*].Instances[*].{Instance:InstanceId,PublicDens:PublicDnsName,Name:Tags[?Key=='Name']|[0].Value}" \
            --output text
        return
    fi

    if [ "$task" == "terminate" ] ; then
        local host_name=$2
        if [ "$host_name" == "." ] ; then
            local host_name=""
        fi
        if [ -z "$host_name" ] ; then
            local host_name=$abcli_host_name
        fi

        # https://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html
        aws ec2 \
            terminate-instances \
            --instance-ids $host_name
        return
    fi

    abcli_log_error "-abcli: instance: $task: command not found."
}