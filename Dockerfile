FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install apache2
RUN a2enmod rewrite 
RUN apt-get -y install software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get -y install php7.2 php7.2-gd

RUN sed -i -e 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g' /etc/apache2/mods-enabled/dir.conf
RUN sed -i -e 's%DocumentRoot /var/www/html%DocumentRoot /var/www/html/public%g' /etc/apache2/sites-available/000-default.conf
RUN sed -i -e 's%AllowOverride None%AllowOverride All%g' /etc/apache2/apache2.conf
COPY /qrcode /var/www/html
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
EXPOSE 80
