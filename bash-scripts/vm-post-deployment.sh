#!/bin/bash

# This script is intended to be run on a fresh install ubuntu vm
sudo apt update && sudo apt upgrade -y

# Install system components
sudo apt install -y qemu-guest-agent nano curl wget nano git gnupg iputils-ping

# ########## Install PowerShell ##########

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

# Restart the shell so that PATH changes take effect
nohup sudo reboot &>/dev/null & exit