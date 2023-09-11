#!/bin/bash
# This script is intended to be run on a fresh install of Proxmox VE

# Make the scripts in bash-scripts folder executable
chmod +x bash-scripts/*.sh

# For NON Enterprise List, rename the Enterprise source list file in "/etc/apt/sources.list.d/", otherwise it will show "non authorized repo"
[ -f /etc/apt/sources.list/pve-enterprise.list ] && mv /etc/apt/sources.list/pve-enterprise.list /etc/apt/sources.list/pve-enterprise.list.bak -f

apt update
apt install -y curl wget nano git vim curl
apt -y full-upgrade

########## Install PowerShell ##########

# Install PowerShell only if it is not already installed
if [ ! -f /usr/bin/pwsh ]; then
    # Install system components
    apt update  && apt install -y curl gnupg apt-transport-https

    # Install snapd, (package manager for snap packages)
    apt install snapd -y

    # Install PowerShell via the Snap package manager
    snap install powershell --classic

fi

# Restart the shell so that PATH changes take effect
[ -f /var/run/reboot-required ] && reboot -f