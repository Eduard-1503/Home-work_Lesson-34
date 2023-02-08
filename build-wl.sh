#!/bin/bash


# Настраиваю совй часовой пояс (чтобы файл лога был удобочитаемее)
timedatectl set-timezone Europe/Moscow


# Создаю файл конфигурации сервиса парсера лога
touch /etc/sysconfig/watchlog
cat << EOF > /etc/sysconfig/watchlog
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF


# Создаю тестовый log files и пишу туда произвольные строки (15 первых строк из лог файла message)
# + плюс ключевое слово ‘ALERT’
touch /var/log/watchlog.log
head -n 15 /var/log/messages > /var/log/watchlog.log
echo "ALERT" >> /var/log/watchlog.log


# Создаю скрипт для парсинга тестового лог файла 
touch /opt/watchlog.sh
cat << EOF > /opt/watchlog.sh
#!/bin/bash
WORD=\$1
LOG=\$2
DATE=\`date\`

if grep \$WORD \$LOG &> /dev/null
then
    logger "\$DATE: I found word, Master!"
else
    exit 0
fi
EOF


# Нарезаю права на исполнение выше созданного скрипта
chmod +x /opt/watchlog.sh


# Создаю юнит-сервис парсинга лог файла
touch /etc/systemd/system/watchlog.service
cat << EOF > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$WORD \$LOG
EOF


# Создаю юнит-таймер для запуска выше созданного юнит-сервиса
touch /etc/systemd/system/watchlog.timer
cat << EOF > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
EOF


# Стартую юнит-таймер
systemctl start watchlog.timer


# Cтартую юнит сервис (юнит-таймер почемуто его не запускает). 
# Если стартую из скрипта то таймер отрабатывае не по плану (каждые 30 секунд)
# каждый раз при старте VM время между запусками скрипта разное,
# если стартую в ручную все работает нормально.
systemctl start watchlog.service


# Подключаю репозиторий epel
yum -y install epel-release


# Устанавливаю spawn-fcgi
yum -y install spawn-fcgi php php-cli mod_fcgid httpd


# Создаю файл конфигурации сервиса spawn-fcgi
cat << EOF > /etc/sysconfig/spawn-fcgi
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF


# Создаю юнит-сервис spawn-fcgi
cat << EOF > /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
EOF


# Стартую юнит-сервис spawn-fcgi
systemctl start spawn-fcgi


# Создаю файл конфигурации юнит-сервиса httpd-1
touch /etc/sysconfig/httpd-first
cat << EOF > /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
EOF


# Создаю файл конфигурации юнит-сервиса httpd-2
touch /etc/sysconfig/httpd-second
cat << EOF > /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
EOF


# Создаю конфигурационный файл apache httpd первого инстанса сервера
cat << EOF > /etc/httpd/conf/first.conf
ServerRoot "/etc/httpd"
PidFile /var/run/httpd-first.pid
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF


# Создаю конфигурационный файл apache httpd второго инстанса сервера
cat << EOF > /etc/httpd/conf/second.conf
ServerRoot "/etc/httpd"
PidFile /var/run/httpd-second.pid
Listen 8080
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF


# Создаю юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами
cat << EOF > /etc/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-
init.service
Documentation=man:httpd.service(8)
[Service]
Type=notify
Environment=LANG=C
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF


# Стартую первый инстанс сервера apache
systemctl start httpd@first


# Стартую второй инстанс сервера apache
systemctl start httpd@second
