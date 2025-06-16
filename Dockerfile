FROM php:8.2-fpm-alpine

# تثبيت الحزم المطلوبة + PostgreSQL
RUN apk add --no-cache \
    nginx \
    curl \
    git \
    unzip \
    zip \
    libzip-dev \
    oniguruma-dev \
    autoconf \
    gcc \
    g++ \
    make \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    icu-dev \
    postgresql-dev # ✅ إضافة دعم PostgreSQL

# إعداد GD وتحميل الامتدادات المطلوبة
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd pdo_pgsql zip bcmath opcache intl # ✅ استخدام pdo_pgsql بدلًا من pdo_mysql

# تحميل Composer الرسمي من Docker Hub
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# تعيين مجلد العمل
WORKDIR /var/www/html

# نسخ ملفات المشروع إلى داخل الحاوية
COPY . .

# تثبيت مكتبات PHP بدون حزم التطوير
RUN composer install --no-dev --optimize-autoloader

# نسخ ملف إعداد Nginx
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# فتح المنفذ 80
EXPOSE 80

# تشغيل PHP-FPM و Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
