#! /usr/bin/env bash

function abcli_seed() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name seed [output=clipboard/key/screen,target=./ec2/jetson/mac/rpi]" \
            "generate an ec2/jetson/mac/rpi seed and output to clipboard/key/screen."
        abcli_help_line "$abcli_cli_name seed eject" \
            "eject seed"
        return
    fi

    if [ "$task" == "eject" ] ; then
        if [[ "$abcli_is_jetson" == true ]] ; then
            sudo eject /media/abcli/SEED
        else
            sudo diskutil umount /Volumes/seed
        fi
        return
    fi

    local options="$1"
    local target=$(abcli_option "$options" "target" ec2)
    local output=$(abcli_option "$options" "output" screen)

    if [ "$target" == "." ] ; then
        for target in ec2 jetson mac rpi ; do
            abcli_seed $(abcli_option_update "$options" target $target) ${@:2}
        done
        return
    fi

    if [ "$output" == "key" ] ; then
        if [[ "$abcli_is_jetson" == true ]] ; then
            local seed_path="/media/abcli/SEED"
        else
            local seed_path="/Volumes/seed"
        fi

        if [ ! -d "$seed_path" ] ; then
            abcli_log_error "-abcli: seed: usb key not found."
            return
        fi
    fi

    abcli_log "seed: $abcli_fullname -$target-> $output"

    local sudo_prefix="sudo "
    local delim="\n"
    local delim_section="\n\n"
    local base64="base64"
    seed="#! /bin/bash$delim"
    if [ "$output" == "clipboard" ] ; then
        local delim="; "
        local delim_section="; "
        seed=""
    fi
    if [ "$abcli_is_ubuntu" == true ] ; then
        # https://superuser.com/a/1225139
        local base64="base64 -w 0"
    fi

    seed="${seed}echo \"$abcli_fullname seed\"$delim_section"

    seed="$seed"'eval "$(ssh-agent -s)"'"$delim_section"

    seed="$seed${sudo_prefix}rm -rf ~/.aws$delim"
    seed="$seed${sudo_prefix}mkdir ~/.aws$delim_section"

    seed="${seed}aws_config=\"$(cat ~/.aws/config | $base64)\"$delim"
    seed="${seed}echo \${aws_config} | base64 --decode > aws_config$delim"
    seed="$seed${sudo_prefix}mv aws_config ~/.aws/config$delim_section"

    seed="${seed}aws_credentials=\"$(cat ~/.aws/credentials | $base64)\"$delim"
    seed="${seed}echo \${aws_credentials} | base64 --decode > aws_credentials$delim"
    seed="$seed${sudo_prefix}mv aws_credentials ~/.aws/credentials$delim_section"

    seed="${seed}${sudo_prefix}mkdir -p ~/.ssh$delim_section"

    seed="${seed}git_ssh_key=\"$(cat ~/.ssh/$abcli_git_ssh_key_name | $base64)\"$delim"
    seed="${seed}echo \$git_ssh_key | base64 --decode >> git_ssh_key$delim"
    seed="$seed${sudo_prefix}mv git_ssh_key ~/.ssh/$abcli_git_ssh_key_name$delim"
    seed="${seed}chmod 600 ~/.ssh/$abcli_git_ssh_key_name$delim"
    seed="${seed}ssh-add -k ~/.ssh/$abcli_git_ssh_key_name$delim_section"

    seed="${seed}ssh-keyscan github.com >> ~/.ssh/known_hosts$delim_section"

    seed="${seed}"'ssh -T git@github.com'"$delim_section"

    seed="${seed}cd; mkdir -p git; cd git$delim"
    seed="${seed}git clone git@github.com:kamangir/awesome-bash-cli.git$delim"
    seed="${seed}cd awesome-bash-cli${delim}"
    seed="${seed}git checkout $abcli_git_branch; git pull$delim"
    seed="${seed}cd ..$delim_section"

    pushd $abcli_path_bash/bootstrap/config > /dev/null
    local filename
    for filename in *.sh *.json *.pem ; do
        seed="${seed}content=\"$(cat $filename | $base64)\"$delim"
        seed="${seed}echo \$content | base64 --decode > ~/git/awesome-bash-cli/bash/bootstrap/config/$filename$delim_section"
    done
    popd > /dev/null

    seed="${seed}source ./abcli/bash/abcli.sh$delim_section"

    if [ "$target" == "ec2" ] ; then
        seed="${seed}source ~/.bash_profile$delim_section"
    elif [ "$target" == "rpi" ] ; then
        seed="${seed}source ~/.bashrc$delim_section"
    fi

    if [ "$output" == "clipboard" ] ; then
        if [ "$abcli_is_mac" == true ] ; then
            echo $seed | pbcopy
        elif [ "$abcli_is_ubuntu" == true ] ; then
            echo $seed | xclip -sel clip
        fi
    elif [ "$output" == "key" ] ; then
        mkdir -p $seed_path/abcli/

        filename="$seed_path/abcli/$target"

        echo -en $seed > $filename.sh
        chmod +x $filename.sh

        echo "{\"version\":$abcli_version}" > $filename.json

        abcli_log "seed -> $filename."
    elif [ "$output" == "screen" ] ; then
        printf "$GREEN$seed$NC\n"
    else
        abcli_log_error "-abcli: seed: $output: output not found."
    fi
}