#! /usr/bin/env bash

function abcli_terraform() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli terraform" \
            "terraform this machine."
        abcli_show_usage "abcli terraform cat" \
            "cat terraform files."
        abcli_show_usage "abcli terraform disable" \
            "disable terraform."
        abcli_show_usage "abcli terraform enable" \
            "enable terraform."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.modules.terraform --help
        fi
        return
    fi

    if [ "$task" == "cat" ]; then

        if [[ "$abcli_is_mac" == true ]]; then
            abcli_log_local_and_cat ~/.bash_profile
            return
        fi

        if [[ "$abcli_is_rpi" == true ]]; then
            abcli_log_local_and_cat "/home/pi/.bashrc"
            if [[ "$abcli_is_headless" == false ]]; then
                abcli_log_local_and_cat "/etc/xdg/lxsession/LXDE-pi/autostart"
            fi
            return
        fi

        if [[ "$abcli_is_ubuntu" == true ]]; then
            if [[ "$abcli_is_ec2" == true ]]; then
                abcli_log_local_and_cat "/home/$USER/.bash_profile"
            else
                abcli_log_local_and_cat "/home/$USER/.bashrc"

                if [[ "$abcli_is_jetson" == true ]]; then
                    abcli_log_local_and_cat "/home/$USER/.config/autostart/abcli.desktop"
                fi
            fi
            return
        fi

        return
    fi

    if [ "$task" == "disable" ]; then
        abcli_eval - \
            touch $abcli_path_ignore/disabled
        return
    fi

    if [ "$task" == "enable" ]; then
        rm -v $abcli_path_ignore/disabled
        return
    fi

    if [[ "$abcli_is_headless" == false ]] && [[ "$abcli_is_mac" == false ]] && [[ "$abcli_is_docker" == false ]]; then
        rm $abcli_path_ignore/background*
        local background_image=$abcli_path_ignore/background-$(abcli_string_timestamp).jpg

        python3 -m abcli.modules.terraform poster \
            --filename $background_image
    fi

    if [[ "$abcli_is_mac" == true ]]; then
        abcli_log "terraforming mac"

        # https://davidwalsh.name/desktop-wallpaper-command-line
        # osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$background_image\""

        sudo python3 -m abcli.modules.terraform \
            terraform \
            --target mac \
            --user $USER
        return
    fi

    if [[ "$abcli_is_rpi" == true ]]; then
        abcli_log "terraforming rpi"

        if [[ "$abcli_is_headless" == false ]]; then
            # https://www.raspberrypi.org/forums/viewtopic.php?t=174165#p1113064
            pcmanfm \
                --set-wallpaper $background_image \
                --wallpaper-mode center
        fi

        sudo python3 -m abcli.modules.terraform \
            terraform \
            --is_headless $abcli_is_headless \
            --target rpi \
            --user pi
        return
    fi

    if [[ "$abcli_is_ubuntu" == true ]] &&
        [[ "$abcli_is_docker" == false ]] &&
        [[ "$abcli_is_aws_batch" == false ]]; then
        abcli_log "terraforming ubuntu"

        if [[ "$abcli_is_jetson" == true ]]; then
            local desktop_environment=$(abcli_jetson_get_desktop_environment)
            abcli_log "terraforming jetson:$desktop_environment"

            # https://forums.developer.nvidia.com/t/how-to-run-a-python-program-as-soon-as-power-is-turned-on-jetson-nano-jetpack/168757/9
            sudo mkdir -p /home/$USER/.config/autostart/
            sudo cp $abcli_path_assets/jetson/abcli.desktop /home/$USER/.config/autostart/

            if [[ "$desktop_environment" == "GNOME" ]]; then
                # https://askubuntu.com/a/69500
                gsettings set \
                    org.gnome.desktop.background \
                    picture-uri file://$background_image
                # https://bytefreaks.net/gnulinux/bash/gnome3-how-to-scale-background-image
                gsettings set \
                    org.gnome.desktop.background \
                    picture-options "scaled"
                # https://askubuntu.com/a/699567
                gsettings set \
                    org.gnome.desktop.background \
                    primary-color "#000000"
                gsettings set \
                    org.gnome.desktop.background \
                    secondary-color "#000000"
                gsettings set \
                    org.gnome.desktop.background \
                    color-shading-type "solid"
            elif [[ "$desktop_environment" == "LXDE" ]]; then
                pcmanfm \
                    --set-wallpaper $background_image \
                    --wallpaper-mode center
            else
                abcli_log_error "unknown desktop environment: '$desktop_environment'."
            fi
        fi

        if [[ "$abcli_is_ec2" == true ]]; then
            abcli_log "terraforming ec2"
            sudo cp \
                $abcli_path_assets/aws/ec2_bash_profile \
                /home/$USER/.bash_profile
        else
            sudo python3 -m abcli.modules.terraform \
                terraform \
                --target ubuntu \
                --user "$USER"
        fi
        return
    fi
}
