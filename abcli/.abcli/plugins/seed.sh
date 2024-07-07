#! /usr/bin/env bash

function abcli_seed() {
    local task=$(abcli_unpack_keyword $1)

    local list_of_seed_targets="cloudshell|docker|ec2|jetson|headless_rpi|mac|rpi|sagemaker|sagemaker-system"

    if [ "$task" == "help" ]; then
        local options="clipboard|filename=<filename>|key|screen,env=<env-name>,eval,plugin=<plugin-name>,~log"
        abcli_show_usage "@seed$ABCUL[<target>|$list_of_seed_targets]$ABCUL[$options]$ABCUL[$abcli_scripts_options]$ABCUL<command-line>" \
            "generate and output a seed 🌱."
        abcli_show_usage "@seed eject" \
            "eject seed 🌱."
        return
    fi

    local base64="base64"
    # https://superuser.com/a/1225139
    [[ "$abcli_is_ubuntu" == true ]] && base64="base64 -w 0"

    # internal function.
    if [ "$task" == "add_file" ]; then
        local source_filename=$2

        local destination_filename=$3

        local var_name=_abcli_seed_$(echo $source_filename | tr / _ | tr . _ | tr - _ | tr \~ _ | tr \$ _)

        local seed="$var_name=\"$(cat $source_filename | $base64)\"$delim"
        seed="${seed}echo \$$var_name | base64 --decode > $var_name$delim"
        seed="$seed${sudo_prefix}mv -v $var_name $destination_filename"

        echo $seed
        return
    fi

    if [ "$task" == "eject" ]; then
        if [[ "$abcli_is_jetson" == true ]]; then
            sudo eject /media/abcli/SEED
        else
            sudo diskutil umount /Volumes/seed
        fi
        return
    fi

    local seed=""

    local target=$(abcli_clarify_input $1 ec2)

    local options=$2
    local do_log=$(abcli_option_int "$options" log 1)
    local do_eval=$(abcli_option_int "$options" eval 0)
    local output=$(abcli_option_choice "$options" clipboard,key,screen clipboard)
    [[ "$abcli_is_sagemaker" == true ]] &&
        output=screen

    local delim="\n"
    local delim_section="\n\n"
    if [ "$output" == "clipboard" ]; then
        delim="; "
        delim_section="; "
    fi

    local env_name=""
    [[ "$target" == "ec2" ]] &&
        env_name="worker"
    env_name=$(abcli_option "$options" env $env_name)

    local sudo_prefix="sudo "
    [[ "$target" == "sagemaker" ]] &&
        sudo_prefix=""

    if [ "$output" == "key" ]; then
        local seed_path="/Volumes/seed"
        [[ "$abcli_is_jetson" == true ]] &&
            seed_path="/media/abcli/SEED"

        if [ ! -d "$seed_path" ]; then
            abcli_log_error "-abcli: seed: usb key not found."
            return 1
        fi

        mkdir -p $seed_path/abcli/
    fi

    [[ "$do_log" == 1 ]] &&
        abcli_log "$abcli_fullname seed 🌱 -$output-> $target"

    local seed="#! /bin/bash$delim"
    [[ "$output" == "clipboard" ]] && seed=""

    seed="${seed}echo \"$abcli_fullname seed for $target\"$delim_section"

    if [[ "|$list_of_seed_targets|" != *"|$target|"* ]]; then
        # expected to append to/update $seed
        abcli_seed_${target} "${@:2}"
    else
        if [ "$target" == docker ]; then
            seed="${seed}source /root/git/awesome-bash-cli/abcli/.abcli/abcli.sh$delim"
        else
            if [[ "$target" != sagemaker ]]; then
                if [ -d "$HOME/.kaggle" ]; then
                    seed="${seed}mkdir -p \$HOME/.kaggle$delim"
                    seed="$seed$(abcli_seed add_file $HOME/.kaggle/kaggle.json \$HOME/.kaggle/kaggle.json)$delim"
                    seed="${seed}chmod 600 \$HOME/.kaggle/kaggle.json$delim_section"
                else
                    abcli_log_warning "-abcli: seed: kaggle.json not found."
                fi
            fi

            if [[ "$target" != sagemaker* ]] && [[ "$target" != cloudshell ]]; then
                seed="$seed${sudo_prefix}rm -rf ~/.aws$delim"
                seed="$seed${sudo_prefix}mkdir ~/.aws$delim_section"
                seed="$seed$(abcli_seed add_file $HOME/.aws/config \$HOME/.aws/config)$delim"
                seed="$seed$(abcli_seed add_file $HOME/.aws/credentials \$HOME/.aws/credentials)$delim_section"
            fi

            if [[ "|cloudshell|sagemaker|" != *"|$target|"* ]]; then
                seed="${seed}${sudo_prefix}mkdir -p ~/.ssh$delim_section"
                seed="$seed"'eval "$(ssh-agent -s)"'"$delim_section"
                seed="$seed$(abcli_seed add_file $HOME/.ssh/$abcli_git_ssh_key_name \$HOME/.ssh/$abcli_git_ssh_key_name)$delim"
                seed="${seed}chmod 600 ~/.ssh/$abcli_git_ssh_key_name$delim"
                seed="${seed}ssh-add -k ~/.ssh/$abcli_git_ssh_key_name$delim_section"
            fi

            if [[ "$target" == "sagemaker-system" ]]; then
                git_seed

                # https://chat.openai.com/c/8bdce889-a9fa-41c2-839f-f75c14d48e52
                seed="${seed}conda install -y unzip$delim_section"
            fi

            if [[ "$target" == "sagemaker" ]]; then
                seed="${seed}apt-get update$delim"
                seed="${seed}apt install -y libgl1-mesa-glx$delim_section"
            fi

            if [[ "$target" == *"rpi" ]]; then
                seed="${seed}ssh-keyscan github.com | sudo tee -a ~/.ssh/known_hosts$delim_section"
            fi

            if [[ "$target" != sagemaker ]] && [[ "$target" != cloudshell ]]; then
                seed="${seed}"'ssh -T git@github.com'"$delim_section"
            fi

            if [[ "$target" == *"rpi" ]]; then
                # https://serverfault.com/a/1093530
                # https://packages.ubuntu.com/bionic/all/ca-certificates/download
                certificate_name="ca-certificates_20211016ubuntu0.18.04.1_all"
                seed="${seed}wget --no-check-certificate http://security.ubuntu.com/ubuntu/pool/main/c/ca-certificates/$certificate_name.deb$delim"
                seed="$seed${sudo_prefix}sudo dpkg -i $certificate_name.deb$delim_section"

                seed="$seed${sudo_prefix}apt-get update --allow-releaseinfo-change$delim"
                seed="$seed${sudo_prefix}apt-get install -y ca-certificates libgnutls30$delim"
                seed="$seed${sudo_prefix}apt-get --yes --force-yes install git$delim_section"
            fi

            local repo_address="git@github.com:kamangir/awesome-bash-cli.git"
            [[ "$target" == sagemaker-system ]] &&
                repo_address="https://github.com/kamangir/awesome-bash-cli"

            if [[ "$target" == sagemaker ]]; then
                seed="${seed}pip install --upgrade pip$delim_section"
                seed="${seed}cd git/awesome-bash-cli${delim}"
            else
                seed="${seed}cd; mkdir -p git; cd git$delim"
                seed="${seed}git clone $repo_address$delim"
                seed="${seed}cd awesome-bash-cli${delim}"
                seed="${seed}git checkout $abcli_git_branch; git pull$delim_section"
            fi

            seed="$seed$(abcli_seed \
                add_file \
                $HOME/git/awesome-bash-cli/.env \
                \$HOME/git/awesome-bash-cli/.env)$delim_section"

            if [ "$target" == "headless_rpi" ]; then
                seed="${seed}touch ~/storage/temp/ignore/headless$delim_section"
            fi

            if [ "$target" == "rpi" ]; then
                seed="${seed}python3 -m pip install --upgrade pip$delim"
                seed="${seed}pip3 install -e .$delim"
                seed="${seed}sudo python3 -m pip install --upgrade pip$delim"
                seed="${seed}sudo pip3 install -e .$delim_section"
            elif [ "$target" == "headless_rpi" ]; then
                seed="${seed}sudo apt-get --yes --force-yes install python3-pip$delim"
                seed="${seed}pip3 install -e .$delim"
                seed="${seed}sudo pip3 install -e .$delim_section"
            else
                seed="${seed}pip3 install -e .$delim_section"
            fi

            seed="${seed}source ./abcli/.abcli/abcli.sh$delim_section"

            if [ "$target" == "ec2" ]; then
                seed="${seed}source ~/.bash_profile$delim_section"
            elif [ "$target" == "rpi" ]; then
                seed="${seed}source ~/.bashrc$delim_section"
            fi

            if [ ! -z "$env_name" ]; then
                seed="${seed}abcli_env dot copy $env_name$delim"
                seed="${seed}abcli init$delim_section"
            fi

            if [[ "$target" == sagemaker ]]; then
                local plugin_name=$(abcli_option "$options" plugin)

                [[ ! -z "$plugin_name" ]] &&
                    seed="${seed}abcli_conda create name=$plugin_name,~recreate$delim"
            fi
        fi
    fi

    [[ "$do_eval" == 1 ]] &&
        seed="${seed}abcli_eval ${@:3}$delim_section"

    [[ "$target" == sagemaker* ]] &&
        abcli_log_warning "run \"bash\" before pasting the seed."

    if [ "$output" == "clipboard" ]; then
        if [ "$abcli_is_mac" == true ]; then
            echo $seed | pbcopy
        elif [ "$abcli_is_ubuntu" == true ]; then
            echo $seed | xclip -sel clip
        fi

        [[ "$do_log" == 1 ]] &&
            abcli_log "📋 paste the seed 🌱 in the $target terminal."
    elif [ "$output" == "key" ] || [ "$output" == "filename" ]; then
        filename=$(abcli_option "$options" filename $abcli_object_path/seed)
        [[ "$output" == "key" ]] &&
            filename="$seed_path/abcli/$target"

        echo -en $seed >$filename.sh
        chmod +x $filename.sh

        echo "{\"version\":\"$abcli_version\"}" >$filename.json

        [[ "$do_log" == 1 ]] &&
            abcli_log "seed 🌱 -> $filename."
    elif [ "$output" == "screen" ]; then
        printf "$GREEN$seed$NC\n"
    else
        abcli_log_error "this should not happen - output: $output".
        return 1
    fi
}
