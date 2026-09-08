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

# CRITICAL: Create cache directories BEFORE composer install
RUN mkdir -p bootstrap/cache \
    && mkdir -p storage/framework/cache \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/logs \
    && mkdir -p storage/installed \
    && chmod -R 775 storage bootstrap/cache

# Create empty cache files
RUN echo "<?php return [];" > bootstrap/cache/services.php \
    && echo "<?php return [];" > bootstrap/cache/packages.php \
    && chmod 775 bootstrap/cache/*

# Create .env file
RUN if [ -f .env.example ]; then \
        cp .env.example .env; \
    else \
        echo "APP_ENV=production" > .env && \
        echo "APP_DEBUG=false" >> .env && \
        echo "APP_URL=https://my-hr-pro.onrender.com" >> .env; \
    fi && \
    chmod 644 .env

# Install dependencies (with --no-scripts to avoid post-autoload-dump)
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Now run post-autoload-dump manually
RUN php artisan package:discover --ansi || echo "Package discovery completed"

# Install Node dependencies and build
RUN npm install && npm run build

# Configure Apache
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan key:generate --force --no-interaction && \
    php artisan migrate --force && \
    apache2-foreground"