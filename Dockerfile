FROM richarvey/nginx-php-fpm:3.1.6

# انسخ كل ملفات المشروع إلى داخل الحاوية
COPY . .

# إعداد مجلد التشغيل لـ PHP-FPM
RUN mkdir -p /var/www/html/run && \
    chmod 775 /var/www/html/run && \
    chown www-data:www-data /var/www/html/run

# حذف vendor و lock file إن وجدت، ثم إعادة تثبيت نظيف
RUN rm -rf vendor composer.lock && \
    composer clear-cache && \
    composer install --no-interaction --prefer-dist --optimize-autoloader

# إعطاء صلاحيات للمجلدات اللي Laravel يحتاج يكتب فيها
RUN chmod -R 775 storage bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache

# توليد APP_KEY تلقائيًا (إذا مش موجود)
RUN php artisan key:generate || true

# إعدادات البيئة
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
