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

# Expose port 8000 (Laravel's default serve port)
EXPOSE 8000

# Start PHP-FPM and Nginx (or just PHP-FPM if using a web server like Caddy/Nginx in a separate container or Render's built-in web server)
# For Render, we'll use php artisan serve
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=${PORT}"]


