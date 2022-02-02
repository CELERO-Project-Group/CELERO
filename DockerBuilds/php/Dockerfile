#FROM php:5.6-apache
FROM php:7.4-apache

# Install the postgres connector
#RUN apt-get update && apt-get install -y libpq-dev php5-pgsql && docker-php-ext-install pdo pdo_pgsql && apt-get install -y #libcurl3 && docker-php-ext-install curl

RUN apt-get update \
    && apt-get install -y --no-install-recommends  libpq-dev libpq5 \
    && apt-get install -y zlib1g-dev \
    && apt-get install -y libzip-dev \
    && apt-get install -y zip \
    && docker-php-ext-install pgsql \
    && docker-php-ext-install pdo pdo_pgsql \
    && docker-php-ext-install zip \
    && apt-get install -y libcurl4 \
    && apt-get purge -y --auto-remove libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Codeigniter needs to rewrite urls
RUN a2enmod rewrite

# The ecoman application
#COPY src/ /var/www/html/

# Configure environment and database connection
COPY config/php.ini /usr/local/etc/php

 
