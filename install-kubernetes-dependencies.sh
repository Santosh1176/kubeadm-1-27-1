#!/bin/bash -e

configure_hosts_file ()
{
sudo tee /etc/hosts<<EOF
192.168.56.8 kubemaster
192.168.56.9 kubenode01
EOF
}


install_required_packages ()
{
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "kubeadm install"
sudo apt update -y
sudo apt -y install curl wget kubelet=1.27.1-00 kubeadm=1.27.1-00 kubectl=1.27.1-00
}

disable_swap ()
{
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
}

configure_sysctl_containerd()
{
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
}

install_containerd()
{
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
echo -ne '\n' | sudo apt-get -y install containerd
sudo -E bash <<EOF
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable kubelet
EOF
}


configure_hosts_file
install_required_packages
disable_swap
configure_sysctl_containerd
install_containerd
