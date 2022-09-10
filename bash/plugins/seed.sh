#! /usr/bin/env bash

function abcli_seed() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli seed [cookie=<cookie-name>,filename=<filename>,~log,output=clipboard|file|key|screen,target=.|ec2|jetson|headless_rpi|mac|rpi]" \
            "generate and output a seed."
        abcli_help_line "abcli seed eject" \
            "eject seed."
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

    local options=$1
    local do_log=$(abcli_option_int "$options" log 1)
    local output=$(abcli_option "$options" output screen)
    local target=$(abcli_option "$options" target ec2)

    local cookie_name=""
    if [ "$target" == "ec2" ] ; then
        local cookie_name="worker"
    fi
    local cookie_name=$(abcli_option "$options" cookie $cookie_name)

    if [ "$target" == "." ] ; then
        for target in ec2 jetson headless_rpi mac rpi ; do
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

        mkdir -p $seed_path/abcli/
    fi

    if [ "$do_log" == 1 ] ; then
        abcli_log "seed: $abcli_fullname -$target-> $output"
    fi

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

    seed="$seed${sudo_prefix}rm -rf ~/.aws$delim"
    seed="$seed${sudo_prefix}mkdir ~/.aws$delim_section"

    seed="${seed}aws_config=\"$(cat ~/.aws/config | $base64)\"$delim"
    seed="${seed}echo \$aws_config | base64 --decode > aws_config$delim"
    seed="$seed${sudo_prefix}mv aws_config ~/.aws/config$delim_section"

    seed="${seed}aws_credentials=\"$(cat ~/.aws/credentials | $base64)\"$delim"
    seed="${seed}echo \$aws_credentials | base64 --decode > aws_credentials$delim"
    seed="$seed${sudo_prefix}mv aws_credentials ~/.aws/credentials$delim_section"

    seed="${seed}${sudo_prefix}mkdir -p ~/.ssh$delim_section"

    seed="$seed"'eval "$(ssh-agent -s)"'"$delim_section"

    seed="${seed}git_ssh_key=\"$(cat ~/.ssh/$abcli_git_ssh_key_name | $base64)\"$delim"
    seed="${seed}echo \$git_ssh_key | base64 --decode >> git_ssh_key$delim"
    seed="$seed${sudo_prefix}mv git_ssh_key ~/.ssh/$abcli_git_ssh_key_name$delim"
    seed="${seed}chmod 600 ~/.ssh/$abcli_git_ssh_key_name$delim"
    seed="${seed}ssh-add -k ~/.ssh/$abcli_git_ssh_key_name$delim_section"

    if [ "$target" == "headless_rpi" ] ; then
        seed="${seed}ssh-keyscan github.com | sudo tee -a ~/.ssh/known_hosts$delim_section"
    else
        seed="${seed}ssh-keyscan github.com >> ~/.ssh/known_hosts$delim_section"
    fi

    seed="${seed}"'ssh -T git@github.com'"$delim_section"

    if [ "$target" == "headless_rpi" ] ; then
        # https://serverfault.com/a/1093530
        # https://packages.ubuntu.com/bionic/all/ca-certificates/download
        seed="${seed}wget --no-check-certificate http://security.ubuntu.com/ubuntu/pool/main/c/ca-certificates/ca-certificates_20210119~18.04.2_all.deb$delim"
        seed="$seed${sudo_prefix}sudo dpkg -i ca-certificates_20210119~18.04.2_all.deb$delim_section"

        seed="$seed${sudo_prefix}apt-get update --allow-releaseinfo-change$delim"
        seed="$seed${sudo_prefix}apt-get install -y ca-certificates libgnutls30$delim"
        seed="$seed${sudo_prefix}apt-get --yes --force-yes install git$delim_section"
    fi

    seed="${seed}cd; mkdir -p git; cd git$delim"
    seed="${seed}git clone git@github.com:kamangir/awesome-bash-cli.git$delim"
    seed="${seed}cd awesome-bash-cli${delim}"
    seed="${seed}git checkout $abcli_git_branch; git pull$delim_section"

    pushd $abcli_path_bash/bootstrap/config > /dev/null
    local filename
    for filename in *.sh *.json *.pem ; do
        seed="${seed}content=\"$(cat $filename | $base64)\"$delim"
        seed="${seed}echo \$content | base64 --decode > ~/git/awesome-bash-cli/bash/bootstrap/config/$filename$delim_section"
    done
    popd > /dev/null

    if [ "$target" == "headless_rpi" ] ; then
        seed="${seed}touch ~/git/awesome-bash-cli/bash/bootstrap/cookie/headless$delim_section"
    fi

    seed="${seed}pip3 install -e .$delim"

    if [ "$(abcli_list_in "$target" "rpi,headless_rpi")" == "True" ] ; then
        seed="${seed}sudo pip3 install -e .$delim_section"
    fi

    seed="${seed}source ./bash/abcli.sh$delim_section"

    if [ "$target" == "ec2" ] ; then
        seed="${seed}source ~/.bash_profile$delim_section"
    elif [ "$target" == "rpi" ] ; then
        seed="${seed}source ~/.bashrc$delim_section"
    fi

    if [ ! -z "$cookie_name" ] ; then
        seed="${seed}abcli cookie copy $cookie_name$delim"
        seed="${seed}abcli init$delim_section"
    fi

    if [ "$output" == "clipboard" ] ; then
        if [ "$abcli_is_mac" == true ] ; then
            echo $seed | pbcopy
        elif [ "$abcli_is_ubuntu" == true ] ; then
            echo $seed | xclip -sel clip
        fi
    elif [ "$output" == "key" ] || [ "$output" == "file" ] ; then
        if [ "$output" == "key" ] ; then
            local filename="$seed_path/abcli/$target"
        else
            local filename=$(abcli_option "$options" filename $abcli_object_path/seed)
        fi

        echo -en $seed > $filename.sh
        chmod +x $filename.sh

        echo "{\"version\":\"$abcli_version\"}" > $filename.json

        abcli_log "seed -> $filename."
    elif [ "$output" == "screen" ] ; then
        printf "$GREEN$seed$NC\n"
    else
        abcli_log_error "-abcli: seed: $output: output not found."
    fi
}