#!/bin/bash

# Update
yum -y update

# Install zfs repo
yum -y install http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm

# Import gpg key
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# Install DKMS style packages for correct work ZFS
yum -y install epel-release kernel-devel zfs

# Change ZFS repo
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum -y install zfs

# Add kernel module zfs
modprobe zfs

# Install wget
yum -y install wget

# Create pools
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
