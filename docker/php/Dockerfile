FROM php:7.4-apache

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install --fix-missing -y libpq-dev 
RUN apt-get install --no-install-recommends -y libpq-dev libpq5
RUN apt-get install -y libxml2-dev libbz2-dev zlib1g-dev libzip-dev zip 
RUN docker-php-ext-install pgsql 
RUN docker-php-ext-install pdo pdo_pgsql 
RUN docker-php-ext-install zip 
RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client curl exif ftp
RUN docker-php-ext-install intl
RUN apt-get -y install --fix-missing zip unzip
RUN apt-get install -y libcurl4 
RUN apt-get purge -y --auto-remove libpq-dev 
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer self-update --2

COPY config/apache.conf /etc/apache2/sites-available/000-default.conf

# Codeigniter needs to rewrite urls
RUN a2enmod rewrite

# Configure environment and database connection
COPY config/php.ini /usr/local/etc/php

RUN service apache2 restart

#RUN chmod -R 0777 /var/www/html/writable

