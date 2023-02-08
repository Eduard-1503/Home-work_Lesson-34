# -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
  :"My-Centos8-for-WL" => {
    :box_name => "centos/stream8",
    :box_version => "20210210.0",
#    :box_name => "centos/7",
#    :box_version => "1804.02",
    :cpus => 2,
    :memory => 1024,
  },
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |vb_3|
      vb_3.vm.box = boxconfig[:box_name]
      vb_3.vm.box_version = boxconfig[:box_version]
      vb_3.vm.host_name = boxname.to_s
      vb_3.vm.provider :virtualbox do |vb|
      end
      vb_3.vm.provision "shell", path: "build-wl.sh"
    end
  end
end
