#!/bin/bash -e

cluster_setup()
{
echo "image pull and cluster setup"
echo "To be executed only on Controlplane node"
sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock --kubernetes-version v1.27.1
sudo kubeadm init   --pod-network-cidr=10.244.0.0/16   --upload-certs --kubernetes-version=v1.27.1  --control-plane-endpoint=172.16.8.10 --ignore-preflight-errors=all  --cri-socket unix:///run/containerd/containerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

create_join_command ()
{
kubeadm token create --print-join-command | tee /home/vagrant/join_command.sh
chmod +x /home/vagrant/join_command.sh
scp /home/vagrant/join_command.sh vagrant@kubenode01:/home/vagrant/join_command.sh
}

install_cilium()
{

echo "Install Cilium as CNI Plugin"

echo "Install Helm as prerequisite"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "Install Cilium using Helm"
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.13.4 --namespace kube-system
} 

cluster_setup
create_join_command
install_cilium

