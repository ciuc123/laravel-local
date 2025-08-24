FROM php:8.0-cli-alpine AS php

WORKDIR /var/www

# System deps commonly needed by Laravel + build tools for pecl/xdebug + linux-headers for Xdebug
RUN apk add --no-cache bash git unzip libpng-dev oniguruma-dev icu-dev libzip-dev mysql-client $PHPIZE_DEPS autoconf g++ make linux-headers

# PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring bcmath

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Optionally remove build dependencies to reduce image size
RUN apk del autoconf g++ make linux-headers

# Xdebug configuration
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log_level=7" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Composer
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer

# Copy app
COPY . .

# Reduce PHP 8.1/8.2 deprecation noise (safe on 8.0 too)
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED" > /usr/local/etc/php/conf.d/error_reporting.ini \
 && echo "display_errors = On" > /usr/local/etc/php/conf.d/display_errors.ini

ENV PORT=8000
ENTRYPOINT ["sh", "./docker/entrypoint.sh"]
