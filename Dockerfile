FROM php:8.0-cli-alpine AS php

WORKDIR /var/www

# System deps commonly needed by Laravel
RUN apk add --no-cache bash git unzip libpng-dev oniguruma-dev icu-dev libzip-dev mysql-client

# PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring bcmath

# Composer
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer

# Copy app
COPY . .

# Reduce PHP 8.1/8.2 deprecation noise (safe on 8.0 too)
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED" > /usr/local/etc/php/conf.d/error_reporting.ini \
 && echo "display_errors = On" > /usr/local/etc/php/conf.d/display_errors.ini

ENV PORT=8000
ENTRYPOINT ["sh", "./docker/entrypoint.sh"]
