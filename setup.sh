#!/bin/bash
# This script is intended to be run on a fresh install of Proxmox VE

# Make the scripts in bash-scripts folder executable
chmod +x bash-scripts/*.sh

apt update
apt install -y curl wget nano git vim curl
apt -y full-upgrade

########## Install PowerShell ##########
# Install system components
apt update  && apt install -y curl gnupg apt-transport-https

# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# For NON Enterprise List, delete or rename the Enterprise source list file in "/etc/apt/sources.list.d/", otherwise it will show "non authorized repo"
mv /etc/apt/sources.list/pve-enterprise.list /etc/apt/sources.list/pve-enterprise.list.bak

# Register the Microsoft Product feed
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

# Install PowerShell
apt update && apt install -y powershell

# Restart the shell so that PATH changes take effect
[ -f /var/run/reboot-required ] && reboot -f