# -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
  :"My-Centos7-for-ZFS" => {
    :box_name => "centos/7",
    :box_version => "2004.01",
    :cpus => 2,
    :memory => 1024,
    :disks => {
      :sata1 => {
        :dfile => '/home/odmin/test_vm/sata1.vdi',
        :size => 512,
        :port => 1
      },
      :sata2 => {
        :dfile => '/home/odmin/test_vm/sata2.vdi',
        :size => 512,
        :port => 2
      },
      :sata3 => {
        :dfile => '/home/odmin/test_vm/sata3.vdi',
        :size => 512,
        :port => 3
      },
      :sata4 => {
        :dfile => '/home/odmin/test_vm/sata4.vdi',
        :size => 512,
        :port => 4
      },
      :sata5 => {
        :dfile => '/home/odmin/test_vm/sata5.vdi',
        :size => 512,
        :port => 5
      },
      :sata6 => {
        :dfile => '/home/odmin/test_vm/sata6.vdi',
        :size => 512,
        :port => 6
      },
      :sata7 => {
        :dfile => '/home/odmin/test_vm/sata7.vdi',
        :size => 512,
        :port => 7
      },
      :sata8 => {
        :dfile => '/home/odmin/test_vm/sata8.vdi',
        :size => 512,
        :port => 8
      }
    }
  },
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |vb_4|
      vb_4.vm.box = boxconfig[:box_name]
      vb_4.vm.box_version = boxconfig[:box_version]
      vb_4.vm.host_name = boxname.to_s
      vb_4.vm.provider :virtualbox do |vb|
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
      vb_4.vm.provision "shell", path: "build-zfs.sh"
    end
  end
end
