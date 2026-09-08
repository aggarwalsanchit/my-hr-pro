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

# Step 1: Create all required directories
RUN mkdir -p bootstrap/cache \
    && mkdir -p storage/framework/{cache,sessions,views} \
    && mkdir -p storage/logs storage/installed \
    && chmod -R 777 storage bootstrap/cache

# Step 2: Create cache files
RUN echo "<?php return [];" > bootstrap/cache/services.php \
    && echo "<?php return [];" > bootstrap/cache/packages.php

# Step 3: Create .env file
RUN echo "APP_ENV=production" > .env && \
    echo "APP_DEBUG=false" >> .env && \
    echo "APP_KEY=${APP_KEY}" >> .env && \
    chmod 644 .env

# Step 4: Install composer without scripts
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Step 5: Manually run post-autoload-dump scripts
RUN composer run-script post-autoload-dump || echo "Post-autoload-dump completed"

# Step 6: Run package discovery explicitly
RUN php artisan package:discover --ansi || echo "Package discovery completed"

# Step 7: Build frontend
RUN npm install && npm run build

# Step 8: Configure Apache
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan migrate --force && \
    apache2-foreground"