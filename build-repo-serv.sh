#!/bin/bash

echo "Настраиваю совй часовой пояс (чтобы файл лога был удобочитаемее)"
timedatectl set-timezone Europe/Moscow

echo "Доустановка необходимых пакетов для сборки rpm"
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc

echo "Загрузка и установка NGIX"
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.22.1-1.el8.ngx.src.rpm

rpm -i /home/vagrant/nginx-1.22.1-1.el8.ngx.src.rpm

echo "Загрузка и распаковка Openssl"
wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz

tar -xvf openssl-1.1.1s.tar.gz

echo "Установка зависимостей"
yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

echo "Корректировка spec файла"
sed -ie 's/    --with-debug/    --with-debug \\\ /' /root/rpmbuild/SPECS/nginx.spec
# STR=`grep -n 'with-debug' /root/rpmbuild/SPECS/nginx.spec | awk '{print $1}' | sed 's/.$//'`
#
# sed -ie '$STR s/.$//' /root/rpmbuild/SPECS/nginx.spec
# Не сумел передать в sed значение переменной STR 122
# подставил руками
#
sed -ie '122 s/.$//' /root/rpmbuild/SPECS/nginx.spec
sed -ie '/with-debug/ a\    --with-openssl=\/home\/vagrant\/openssl-1.1.1s' /root/rpmbuild/SPECS/nginx.spec

echo "Сборка пакета"
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

echo "Установка собранного NGINX"
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.22.1-1.el8.ngx.x86_64.rpm

echo "Запуск NGINX"
systemctl start nginx

echo "Создание локального репозитория"
mkdir /usr/share/nginx/html/repo

cp /root/rpmbuild/RPMS/x86_64/nginx-1.22.1-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo

createrepo /usr/share/nginx/html/repo/

echo "Изменение конфигурации NGINX"
sed -ie '/        index  index.html index.htm;/ a\        autoindex on;' /etc/nginx/conf.d/default.conf

echo "Рестарт nginx"
nginx -s reload
