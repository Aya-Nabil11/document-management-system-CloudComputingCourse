FROM php:8.2-fpm-alpine

# تثبيت أدوات النظام
RUN apk add --no-cache \
    nginx \
    curl \
    git \
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
    g++ \
    bash \
    supervisor \
    openssl

# تثبيت امتدادات PHP المطلوبة من Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip bcmath opcache intl

# تثبيت Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# تحديد مجلد العمل
WORKDIR /var/www

# نسخ ملفات Laravel إلى الحاوية
COPY . .

# إعداد Composer
RUN composer install --no-dev --optimize-autoloader \
    && php artisan key:generate --force \
    && php artisan migrate --force \
    && php artisan config:clear \
    && php artisan route:clear \
    && php artisan config:cache \
    && php artisan route:cache

# إعداد Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# إعداد Supervisor لتشغيل nginx و php-fpm معًا
RUN mkdir -p /var/log/supervisor
RUN echo "[supervisord]
nodaemon=true

[program:php-fpm]
command=/usr/local/sbin/php-fpm

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
" > /etc/supervisord.conf

# فتح البورت 80
EXPOSE 80

# تشغيل Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
