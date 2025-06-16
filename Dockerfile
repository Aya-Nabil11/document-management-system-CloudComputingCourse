FROM php:8.2-fpm-alpine

# تثبيت الحزم المطلوبة
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
    nginx \
    build-base \
    autoconf \
    make \
    g++

# تفعيل إضافات PHP المطلوبة
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip bcmath opcache intl

# تثبيت Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# تحديد مجلد العمل
WORKDIR /var/www/html

# نسخ المشروع بالكامل إلى الحاوية
COPY . .

# نسخ إعدادات Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# إعداد Laravel فقط في وقت التشغيل وليس أثناء البناء
# (لأن .env وقاعدة البيانات مش موجودين في build)
# راح نستخدم startCommand لاحقًا

# فتح المنفذ 80
EXPOSE 80

# بدء PHP-FPM و Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
