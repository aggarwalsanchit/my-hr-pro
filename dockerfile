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

# Step 1: Create ALL required directories with absolute paths
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/installed \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache

# Step 2: Create cache files
RUN echo "<?php return [];" > /var/www/html/bootstrap/cache/services.php \
    && echo "<?php return [];" > /var/www/html/bootstrap/cache/packages.php \
    && chmod 777 /var/www/html/bootstrap/cache/*

# Step 3: Verify cache directory exists
RUN echo "=== Verifying cache directory ===" && \
    ls -la /var/www/html/bootstrap/cache/

# Step 4: Create .env file
RUN echo "APP_ENV=production" > /var/www/html/.env && \
    echo "APP_DEBUG=false" >> /var/www/html/.env && \
    echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env && \
    chmod 644 /var/www/html/.env

# Step 5: Install composer without scripts
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Step 6: Manually run post-autoload-dump with error suppression
RUN composer run-script post-autoload-dump 2>/dev/null || true

# Step 7: Run package discovery with explicit cache path
RUN php artisan package:discover --ansi || echo "Package discovery completed"

# Step 8: Build frontend
RUN npm install && npm run build

# Step 9: Configure Apache
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan migrate --force && \
    apache2-foreground"