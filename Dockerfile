# Set the base image for subsequent instructions
FROM php:7.1-apache

# Update packages
RUN apt-get update

# Install PHP and composer dependencies
RUN apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev

# Clear out the local repository of retrieved package files
RUN apt-get clean

# Install needed extensions
# Here you can install any other extension that you need during the test and deployment process
RUN docker-php-ext-install mcrypt pdo_mysql zip

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel Envoy
RUN composer global require "laravel/envoy=~1.0"

#RUN chown www-data: /var/www/current -R && \
#    chmod 0755 /var/www/current -R
RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laravel.conf && \
    sed -i 's,/var/www/html,/var/www/current/public,g' /etc/apache2/sites-available/laravel.conf && \
    sed -i 's,${APACHE_LOG_DIR},/var/log/apache2,g' /etc/apache2/sites-available/laravel.conf && \
    a2ensite laravel.conf && a2dissite 000-default.conf && a2enmod rewrite
	
# Setup working directory
WORKDIR /var/www

EXPOSE 80
