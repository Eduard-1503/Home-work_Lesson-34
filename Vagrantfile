# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :"My-Centos8-for-Docker" => {
    :box_name => "centos/stream8",
    :cpus => 2,
    :memory => 2048,
  },
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = "Docker-host"
      # box.vm.network "forwarded_port", guest: 4881, host: 4881
      # box.vm.network "public_network", ip: "192.168.0.254", bridge: "wlp2s0"
      box.vm.network "public_network", ip: "192.168.190.254", bridge: "enp3s0"
      box.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "2048"]
        vb.cpus = 2
        needsController = false
      end
    end

    config.vm.provision "ansible" do |ansible|
      ansible.verbose = "vvv"
      ansible.playbook = "provisioning/playbook.yml"
      ansible.become = "true"
    end

  end
end

