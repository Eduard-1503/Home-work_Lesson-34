# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/stream8"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  config.vm.define "serv-repos" do |s|
    s.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    s.vm.hostname = "Server-for-local-repos"
    s.vm.provision "shell", path: "build-repo-serv.sh"
  end

  config.vm.define "client-repos" do |c|
    c.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    c.vm.hostname = "Client-for-local-repos"
    c.vm.provision "shell", path: "build-repo-client.sh"
  end

end
