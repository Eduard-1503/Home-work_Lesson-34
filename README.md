ДЗ № 13: Docker, docker-compose, dockerfile
1. Написать Dockerﬁle на базе apache/nginx который будет содержать две статичные web-страницы
   на разных портах. Например, 80 и 3000.
2. Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам
   localhost:80 и localhost:3000
3. Добавить 2 вольюма. Один для логов приложения, другой для web-страниц. 

 Для проверки представляю Vagrantfile который разворачивает ВМ и с помощью ansible из provisioning/playbook.yml устанавливает на ВМ docker, 
 затем копирует из provisioning/files/ копируются конфигурационные файлы для сборки и запуска docker-container и конфигурации в нем nginx
 (Dockerfile, default.conf, index80.html, index3000.html).
