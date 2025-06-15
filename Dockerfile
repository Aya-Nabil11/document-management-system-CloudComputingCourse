FROM php:8.2-fpm

# تثبيت التبعيات
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    libzip-dev \
    libpq-dev \
    libmcrypt-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# نسخ ملفات المشروع
WORKDIR /var/www
COPY . .

# تثبيت الحزم
RUN composer install --no-dev --optimize-autoloader

# إعطاء صلاحيات التخزين
RUN chown -R www-data:www-data /var/www/storage

CMD php artisan serve --host=0.0.0.0 --port=8080
