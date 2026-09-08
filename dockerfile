FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev \
    zip unzip nodejs npm libzip-dev libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip
RUN a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN mkdir -p storage/framework/{cache,sessions,views} \
    storage/logs storage/installed bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && echo "<?php return [];" > bootstrap/cache/services.php \
    && echo "<?php return [];" > bootstrap/cache/packages.php

# Create .env file if it doesn't exist
RUN if [ -f .env.example ]; then \
        cp .env.example .env; \
    else \
        echo "APP_ENV=production" > .env && \
        echo "APP_DEBUG=false" >> .env && \
        echo "APP_URL=https://my-hr-pro.onrender.com" >> .env; \
    fi && \
    chmod 644 .env

RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build

RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan key:generate --force --no-interaction && \
    php artisan migrate --force && \
    apache2-foreground"