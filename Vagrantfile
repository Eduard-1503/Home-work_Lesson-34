# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  config.vm.define "nfss" do |s|
    s.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    s.vm.hostname = "Server-for-NFS"
    s.vm.provision "shell", path: "build-nfs-server.sh"
  end

  config.vm.define "nfsc" do |c|
    c.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    c.vm.hostname = "Client-for-NFS"
    c.vm.provision "shell", path: "build-nfs-client.sh"
  end

end
