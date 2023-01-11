# -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
  :"My-Centos8-for-RAID" => {
    :box_name => "centos/stream8",
    :box_version => "20210210.0",
    :cpus => 2,
    :memory => 1024,
    :disks => {
      :sata1 => {
        :dfile => './sata1.vdi',
        :size => 250,
        :port => 1
      },
      :sata2 => {
        :dfile => './sata2.vdi',
        :size => 250, # Megabytes
        :port => 2
      },
      :sata3 => {
        :dfile => './sata3.vdi',
        :size => 250,
        :port => 3
      },
      :sata4 => {
        :dfile => './sata4.vdi',
        :size => 250,
        :port => 4
      }
    }
  },
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |vb_2|
      vb_2.vm.box = boxconfig[:box_name]
      vb_2.vm.box_version = boxconfig[:box_version]
      vb_2.vm.host_name = boxname.to_s
      vb_2.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "1024"]
        needsController = false
        boxconfig[:disks].each do |dname, dconf|
          unless File.exist?(dconf[:dfile])
            vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
            needsController =  true
          end
        end
        if needsController == true
          vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
          boxconfig[:disks].each do |dname, dconf|
            vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
          end
        end
      end
      vb_2.vm.provision "shell", path: "build-raid.sh"
    end
  end
end
