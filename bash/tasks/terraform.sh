#! /usr/bin/env bash

function abcli_terraform() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "terraform" \
            "terraform this machine."
        abcli_help_line "terraform cat" \
            "cat terraform files."
        abcli_help_line "$abcli_cli_name terraform disable" \
            "disable terraform."
        abcli_help_line "$abcli_cli_name terraform enable" \
            "enable terraform."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.terraform --help
        fi
        return
    fi

    if [ "$task" == "cat" ] ; then

        if [[ "$abcli_is_mac" == true ]] ; then
            abcli_log_local_and_cat ~/.bash_profile
            return
        fi

        if [[ "$is_rpi" == true ]] ; then
            abcli_log_local_and_cat "/home/pi/.bashrc"
            if [[ "$abcli_is_headless" == false ]] ; then
                abcli_log_local_and_cat "/etc/xdg/lxsession/LXDE-pi/autostart"
            fi
            return
        fi

        if [[ "$abcli_is_ubuntu" == true ]] ; then
            if [[ "$abcli_is_ec2" == true ]] ; then
                abcli_log_local_and_cat "/home/$USER/.bash_profile"
            else
                abcli_log_local_and_cat "/home/$USER/.bashrc"

                if [[ "$abcli_is_jetson" == true ]] ; then
                    abcli_log_local_and_cat "/home/$USER/.config/autostart/abcli.desktop"
                fi
            fi
            return
        fi

        return
    fi

    if [ "$task" == "disable" ] ; then
        touch $abcli_path_bash/abcli_disabled
        return
    fi

    if [ "$task" == "enable" ] ; then
        rm $abcli_path_bash/abcli_disabled
        return
    fi

    abcli_log "terraform: wip"
}
