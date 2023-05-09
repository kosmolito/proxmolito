#!/bin/bash
############ Disable swap & add kernel settings ############
# Disable swap
echo "########## Disabling swap ##########"
sudo swapoff -a
# Comment out swap in /etc/fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab

# Load the following kernel modules on all the nodes
echo "########## Loading kernel modules ##########"
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure the kernel parameters for kubernetes
echo "########## Configuring kernel parameters ##########"
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply the kernel parameters
echo "########## Applying kernel parameters ##########"
sudo sysctl --system


############ Install containerd run time ############
# Install its dependencies.
echo "########## Installing containerd dependencies ##########"
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Enable docker repository
echo "########## Enabling docker repository ##########"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
echo "########## Installing containerd ##########"
sudo apt update && sudo apt install -y containerd.io

# Configure containerd so that it starts using systemd as cgroup.
echo "########## Configuring containerd ##########"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Set runtime-endpoint to containerd.sock
sudo tee /etc/crictl.yaml<<EOF
runtime-endpoint: "unix:///run/containerd/containerd.sock"
timeout: 0
debug: false
EOF

# Restart containerd
echo "########## Restarting containerd ##########"
sudo systemctl restart containerd
sudo systemctl enable containerd

############ Add apt repository for Kubernetes & Install Kubectl, kubeadm & kubelet ############
echo "########## Adding apt repository for Kubernetes ##########"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "########## Installing Kubectl, kubeadm & kubelet ##########"
sudo apt update
sudo apt install wget curl nano vim git etcd kubectl=1.26.4-00 kubeadm=1.26.4-00 kubelet=1.26.4-00 -y
# Mark the packages as hold so that they are not updated automatically
echo "########## Marking the packages as hold so that they are not updated automatically ##########"
sudo apt-mark hold kubelet kubeadm kubectl

echo "########## Installing Helm ##########"
sudo snap install helm --classic
echo "########## Installing k9s ##########"
sudo snap install k9s

############ Install bash completion for kubectl, kubeadm & crictl ############
echo "########## Setting up autocomplete in bash for kubectl ##########"
source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc # add autocomplete permanently to your bash shell, for kubectl alias k.
echo "source <(kubeadm completion bash)" >> ~/.bashrc
echo "source <(crictl completion bash)" >> ~/.bashrc
echo "source <(helm completion bash)" >> ~/.bashrc

echo "########## Kubernetes Installation Done ##########"