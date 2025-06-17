FROM richarvey/nginx-php-fpm:3.1.6

# انسخ كل ملفات المشروع
COPY . .

# إعداد مجلد التشغيل لـ PHP-FPM
RUN mkdir -p /var/www/html/run && \
    chmod 775 /var/www/html/run && \
    chown www-data:www-data /var/www/html/run

# حذف vendor و lock file إن وجدت، ثم تثبيت نظيف
RUN rm -rf vendor composer.lock && \
    composer clear-cache && \
    composer install --no-interaction --prefer-dist --optimize-autoloader

# ضبط صلاحيات المجلدات
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# ملاحظة: لا تولّد APP_KEY داخل Dockerfile (لأنه بيكون `.env` مش موجود)

# إعدادات Laravel & Nginx
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV COMPOSER_ALLOW_SUPERUSER 1

# سكربت التشغيل الأساسي
CMD ["/start.sh"]
