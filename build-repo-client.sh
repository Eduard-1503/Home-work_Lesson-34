#!/bin/bash

echo "Настраиваю совй часовой пояс (чтобы файл лога был удобочитаемее)"
timedatectl set-timezone Europe/Moscow

echo "Добавляю локальный репозиторий"
cat << EOF >> /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=http://192.168.50.10/repo
gpgcheck=0
enabled=1
EOF

echo "Отключаю официальные репозитории"
yum-config-manager --disable appstream
yum-config-manager --disable baseos
yum-config-manager --disable extras

echo "Устанавливаю nginx из локального репозитория Otus"
yum install -y nginx
