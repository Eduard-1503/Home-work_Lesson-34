#!/bin/bash

# Install nfs-utils
yum -y install nfs-utils

# Enable & start firewall
systemctl start firewalld.service
systemctl enable firewalld.service

# Mounted share
mount -t nfs -o vers=3,proto=udp 192.168.50.10:/share /mnt

systemctl daemon-reload
