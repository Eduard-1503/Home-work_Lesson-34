# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/stream8"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vvv"
    ansible.playbook = "provisioning/playbook.yml"
    ansible.become = "true"
  end

  config.vm.define "Server-Nginx" do |s|
    s.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    s.vm.hostname = "Server-Nginx"
    # s.vm.provision "shell", path: "build-nfs-server.sh"
  end

  config.vm.define "Server-Logs" do |c|
    c.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    c.vm.hostname = "Server-Logs"
    # c.vm.provision "shell", path: "build-nfs-client.sh"
  end

end
