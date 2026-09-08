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

# Create directories
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/installed \
    && chmod -R 777 /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache

# Create cache files
RUN echo "<?php return [];" > /var/www/html/bootstrap/cache/services.php \
    && echo "<?php return [];" > /var/www/html/bootstrap/cache/packages.php \
    && chmod 777 /var/www/html/bootstrap/cache/*

# Create .env file
RUN echo "APP_ENV=production" > /var/www/html/.env && \
    echo "APP_DEBUG=true" >> /var/www/html/.env && \
    echo "APP_URL=https://my-hr-pro.onrender.com" >> /var/www/html/.env && \
    echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env && \
    chmod 644 /var/www/html/.env

# Install composer
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Run post-autoload-dump
RUN composer run-script post-autoload-dump 2>/dev/null || true

# Run package discovery
RUN php artisan package:discover --ansi || echo "Package discovery completed"

# ===== FRONTEND BUILD =====
RUN echo "=== Installing Node dependencies ===" && \
    npm install

RUN echo "=== Checking Vite version ===" && \
    npx vite --version

RUN echo "=== Running Vite build ===" && \
    npx vite build

# ===== VERIFY AND FIX MANIFEST =====
RUN echo "=== Checking build output ===" && \
    ls -la /var/www/html/public/ && \
    ls -la /var/www/html/public/build/ 2>/dev/null || echo "Build directory missing" && \
    ls -la /var/www/html/public/build/.vite/ 2>/dev/null || echo ".vite directory missing"

RUN if [ -f /var/www/html/public/build/manifest.json ]; then \
        echo "✅ manifest.json found at root!"; \
    elif [ -f /var/www/html/public/build/.vite/manifest.json ]; then \
        echo "✅ manifest.json found in .vite directory!"; \
        echo "Copying manifest.json to root..."; \
        cp /var/www/html/public/build/.vite/manifest.json /var/www/html/public/build/manifest.json; \
        echo "✅ manifest.json copied to root!"; \
    else \
        echo "❌ manifest.json NOT found!"; \
        echo "Searching for manifest.json..."; \
        find /var/www/html -name "manifest.json" 2>/dev/null || echo "No manifest.json found"; \
        exit 1; \
    fi

# Configure Apache
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && echo "php_flag display_errors on" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan migrate --force && \
    apache2-foreground"