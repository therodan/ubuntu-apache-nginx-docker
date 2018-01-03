FROM ubuntu:16.04

RUN apt-get update && apt-get install -y nginx apache2 libapache2-mod-fastcgi openssl supervisor \
    curl libpng12-dev libjpeg-dev libmcrypt-dev \
    php-fpm php-dev php-gd php-curl php-mysqli php-mbstring php-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Apache
COPY ./conf/apache/ports.conf /etc/apache2/ports.conf
COPY ./conf/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./conf/apache/fastcgi.conf /etc/apache2/mods-available/fastcgi.conf

RUN a2enmod actions && \
	a2enmod rewrite

RUN service php7.0-fpm start

# Nginx
RUN mkdir /etc/nginx/ssl

COPY ./conf/nginx/default /etc/nginx/sites-available/default
COPY ./conf/nginx/basic.conf /etc/nginx/conf.d/basic.conf
COPY ./conf/nginx/ssl.conf /etc/nginx/conf.d/ssl.conf

# Supervisor
COPY ./conf/supervisord.conf /etc/supervisord.conf
RUN chmod 400 /etc/supervisord.conf

EXPOSE 80
EXPOSE 443

COPY ./entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]

CMD /usr/bin/supervisord -n -c /etc/supervisord.conf