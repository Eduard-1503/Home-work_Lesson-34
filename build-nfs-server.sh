#!/bin/bash

# Install nfs-utils
yum -y install nfs-utils

# Enable & start nfs-server
systemctl start nfs-server.service
systemctl enable nfs-server.service

# Create folder shared
mkdir -p /share/upload
chmod 0777 /share/upload

# Create & configure share
touch /etc/exports
echo '/share 192.168.50.11/32(rw,sync,root_squash)' > /etc/exports

exportfs -r

# Enable & start firewall
systemctl start firewalld.service
systemctl enable firewalld.service

# Configure firewall
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --permanent --add-service=mountd
# This port had to be added manually
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --reload

