FROM nginx:latest
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index80.html /usr/share/nginx/html/index80.html
COPY index3000.html /usr/share/nginx/html/index3000.html
VOLUME /var/log/nginx /usr/share/nginx/html
