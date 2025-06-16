FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    libwebp-dev \
    freetype-dev \
    icu-dev \
    mysql-client \
    build-base \
    autoconf \
    make \
    g++

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip bcmath opcache intl

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate application key and run migrations
RUN php artisan key:generate --force
RUN php artisan migrate --force

# ✅ Clear and rebuild Laravel caches (fixes 404 issue)
RUN php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear \
    && php artisan config:cache \
    && php artisan route:cache

# Expose port 8000 (Laravel default port)
EXPOSE 8000

# Start Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=${PORT}"]
