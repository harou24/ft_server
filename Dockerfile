FROM debian:buster

MAINTAINER Haroutioun Achtchian haachtch@student.codam.nl

RUN apt-get update && apt-get upgrade && apt-get -y install nginx mariadb-server mariadb-client php-cli php-mysql php-curl php-gd php-mbstring php-intl php-fpm wget vim unzip ca-certificates libssl1.1
RUN mkdir /utils
COPY srcs/init.sql /utils
COPY srcs/init.sh /utils
COPY srcs/wordpress /etc/nginx/sites-available/
COPY srcs/phpmyadmin /etc/nginx/sites-available/

RUN rm /etc/nginx/sites-available/default
COPY srcs/default /etc/nginx/sites-available/default

RUN rm /etc/php/7.3/fpm/php.ini
COPY srcs/php.ini /etc/php/7.3/fpm/php.ini

RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzvf latest.tar.gz
RUN mv wordpress /var/www/html
RUN rm latest.tar.gz

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.zip
RUN unzip phpMyAdmin-4.9.0.1-all-languages.zip 
RUN mv phpMyAdmin-4.9.0.1-all-languages phpmyadmin
RUN mv phpmyadmin /var/www/html
RUN rm phpMyAdmin-4.9.0.1-all-languages.zip

RUN chown -R www-data:www-data /var/www/html/wordpress/
RUN chmod -R 755 /var/www/html/wordpress/

RUN chown -R www-data:www-data /var/www/html/phpmyadmin
RUN chmod -R 755 /var/www/html/phpmyadmin

COPY srcs/wp-config.php /var/www/html/wordpress

RUN rm /var/www/html/index.nginx-debian.html
RUN service mysql start && mysql -uroot -proot mysql < "/utils/init.sql"

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048\
    -subj '/C=NL/ST=10/L=Amsterdam/O=Codam/CN=harou'\
    -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

EXPOSE 80 443

CMD ["bash", "/utils/init.sh"]