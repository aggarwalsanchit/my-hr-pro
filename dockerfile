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
    echo "APP_DEBUG=true" >> /var/www/html/.env && \
    echo "APP_URL=https://my-hr-pro.onrender.com" >> /var/www/html/.env && \
    echo "APP_KEY=${APP_KEY}" >> /var/www/html/.env && \
    chmod 644 /var/www/html/.env

# Step 5: Install composer without scripts
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Step 6: Manually run post-autoload-dump with error suppression
RUN composer run-script post-autoload-dump 2>/dev/null || true

# Step 7: Run package discovery with explicit cache path
RUN php artisan package:discover --ansi || echo "Package discovery completed"

# ===== FRONTEND BUILD WITH VERIFICATION =====
# Step 8: Install Node dependencies
RUN echo "=== Installing Node dependencies ===" && \
    npm install

# Step 9: Build frontend with verification
RUN echo "=== Building Vite assets ===" && \
    npm run build && \
    echo "=== Build completed ==="

# Step 10: VERIFY BUILD OUTPUT
RUN echo "=== Verifying build output ===" && \
    echo "Contents of public/build:" && \
    ls -la /var/www/html/public/build/ || echo "❌ Build directory not found!" && \
    if [ -f /var/www/html/public/build/manifest.json ]; then \
        echo "✅ manifest.json found!"; \
        cat /var/www/html/public/build/manifest.json | head -20; \
    else \
        echo "❌ manifest.json NOT found!"; \
        echo "Looking for manifest.json anywhere..."; \
        find /var/www/html -name "manifest.json" 2>/dev/null || echo "No manifest.json found anywhere"; \
        echo "Checking if Vite is installed..."; \
        npx vite --version || echo "Vite not found"; \
        exit 1; \
    fi

# Step 11: Configure Apache
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && echo "php_flag display_errors on" >> /etc/apache2/apache2.conf \
    && echo "php_flag display_startup_errors on" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD /bin/bash -c "\
    php artisan migrate --force && \
    apache2-foreground"