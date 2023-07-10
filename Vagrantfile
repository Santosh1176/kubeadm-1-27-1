# -*- mode: ruby -*-
# vi: set ft=ruby :

MASTER_IP       = "192.168.56.8"
NODE_01_IP      = "192.168.56.9"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.2.16"

  boxes = [
    { :name => "kubemaster",  :ip => MASTER_IP,  :cpus => 1, :memory => 2048 },
    { :name => "kubenode01", :ip => NODE_01_IP, :cpus => 1, :memory => 2048 },
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |box|
      box.vm.hostname = opts[:name]
      box.vm.network :private_network, ip: opts[:ip]
 
      box.vm.provider "virtualbox" do |vb|
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
      end
      box.vm.provision "shell", path:"./install-kubernetes-dependencies.sh"
      if box.vm.hostname == "kubemaster" then 
        box.vm.provision "shell", path:"./configure-master-node.sh"
        end
      if box.vm.hostname == "kubenode01" then ##TODO: create some regex to match worker hostnames
        box.vm.provision "shell", path:"./configure-worker-nodes.sh"
      end

    end
  end
end
