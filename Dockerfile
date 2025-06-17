FROM richarvey/nginx-php-fpm:3.1.6

COPY . .

# Ensure the run directory exists and has correct permissions for PHP-FPM socket
RUN mkdir -p /var/www/html/run && chmod 775 /var/www/html/run && chown www-data:www-data /var/www/html/run

# Image config
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1

# Laravel config
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr

# Allow composer to run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

CMD ["/start.sh"]
