#!/bin/bash

SCRIPT=$(basename $0)

error_exit() {
    echo "Usage: $SCRIPT --user <username> --uid <id>"
    exit 1
}

while [[ $# -ge 1 ]]; do
    case $1 in
        --user) shift; NEW_USER=$1;       shift;;
        --uid)  shift; NEW_USER_UID=$1;   shift;;
        *)      echo "Invalid option $1"; error_exit;;
    esac
done

[ -z $NEW_USER ] && echo 'Missing --user option' && error_exit
[ -z $NEW_USER_UID ] && echo 'Missing --uid option' && error_exit

echo "Creating user $NEW_USER"
id -u $NEW_USER &>/dev/null || useradd --groups admin --shell /bin/bash --uid $NEW_USER_UID $NEW_USER

NEW_USER_HOMEDIR=$(sudo -H -u $NEW_USER -s eval 'echo $HOME')
mkdir -pm 700 ${NEW_USER_HOMEDIR}/.ssh
if ! grep -q -s 'vagrant insecure public key' ${NEW_USER_HOMEDIR}/.ssh/authorized_keys; then
    echo "Adding Vagrant public key..."
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' >> ${NEW_USER_HOMEDIR}/.ssh/authorized_keys
    chmod 600 ${NEW_USER_HOMEDIR}/.ssh/authorized_keys
fi

SUDOCOMMAND="[[ -t 0 ]] && exec ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oLogLevel=ERROR -A $NEW_USER@localhost"

if ! grep -q -s "$SUDOCOMMAND" ~vagrant/.bashrc; then
    echo "Adding $NEW_USER to ~vagrant/.bashrc"
    echo $SUDOCOMMAND >> ~vagrant/.bashrc
fi

echo 'Done provision!'
