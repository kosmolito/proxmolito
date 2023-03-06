#!/bin/bash
##################################################################################
#1) Upgrade your Ubuntu servers
sudo apt update
sudo apt -y full-upgrade
[ -f /var/run/reboot-required ] && sudo reboot -f

##################################################################################
#2) Install kubelet, kubeadm and kubectl
sudo apt install curl apt-transport-https -y
curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Then install required packages.
sudo apt update
sudo apt install wget curl nano vim git kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl

##################################################################################
#3) Disable Swap Space
sudo swapoff -a 

# Enable kernel modules and configure sysctl.
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

##################################################################################
#4) Install Container runtime (Master and Worker nodes) ## Installing Containerd ##
# Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start service
sudo su -c "mkdir -p /etc/containerd/"
sudo su -c "containerd config default>/etc/containerd/config.toml"
# Change the false to true
sudo su -c "sed -i 's/systemd_cgroup = false/systemd_cgroup = true/' /etc/containerd/config.toml"

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

#5) Initialize control plane (run on first master node)
# Login to the server to be used as master and make sure that the br_netfilter module is loaded:
# lsmod | grep br_netfilter

# Enable kubelet service.
sudo systemctl enable kubelet

# Pull container images:
sudo kubeadm config images pull

# Enable ipv4 Bridge
sudo sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sudo reboot