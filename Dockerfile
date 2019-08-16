# Set the base image for subsequent instructions
FROM php:7.3-apache

# Install dependencies
RUN apt-get update && pecl install redis && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    default-mysql-client \
    libzip-dev

	
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli pdo_mysql mbstring zip exif pcntl opcache bcmath tokenizer
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd && docker-php-ext-enable opcache redis

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laravel.conf && \
    sed -i 's,/var/www/html,/var/www/apply/current/public,g' /etc/apache2/sites-available/laravel.conf && \
    sed -i 's,${APACHE_LOG_DIR},/var/log/apache2,g' /etc/apache2/sites-available/laravel.conf && \
    a2ensite laravel.conf && a2dissite 000-default.conf && a2enmod rewrite && service apache2 restart
	
# Setup working directory
WORKDIR /var/www

EXPOSE 80
CMD ["apache2-foreground"]
