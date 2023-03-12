#!/bin/bash

# This script is intended to be run on a fresh install ubuntu vm
echo "########## Updating system ##########"
sudo apt update && sudo apt upgrade -y

# Install system components
echo "########## Installing system components ##########"
sudo apt install -y qemu-guest-agent

Echo "########## Enabling qemu-guest-agent ##########"
sudo systemctl enable qemu-guest-agent

echo "########## Installing utility softwares ##########"
sudo apt install -y nano curl wget nano git gnupg iputils-ping dnsutils bash-completion

# ########## Install PowerShell ##########

# Install PowerShell only if it is not already installed
if [ ! -f /usr/bin/pwsh ]; then
    echo "########## Installing PowerShell ##########"
    # Update the list of packages
    sudo apt-get update
    # Install pre-requisite packages.
    sudo apt-get install -y wget apt-transport-https software-properties-common
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get update
    # Install PowerShell
    sudo apt-get install -y powershell
fi

# Restart the shell so that PATH changes take effect
echo "########## System Update & Software Installation Done ##########"
echo "########## Restarting the VM ##########"
nohup sudo reboot &>/dev/null & exit