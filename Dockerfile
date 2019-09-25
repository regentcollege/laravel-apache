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
    libzip-dev \
    zlib1g-dev \
    libicu-dev \
    g++ \
    supervisor

	
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli pdo_mysql mbstring zip exif pcntl opcache bcmath tokenizer
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd && docker-php-ext-enable opcache redis
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./config/laravel.conf /etc/apache2/sites-available/laravel.conf
COPY ./config/laravel.php.ini /etc/apache2/conf.d/laravel.php.ini
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /usr/local/bin/start

RUN mkdir -p /var/www/apply/current/public

RUN a2ensite laravel.conf && a2dissite 000-default.conf && chmod u+x /usr/local/bin/start && a2enmod rewrite
	
# Setup working directory
WORKDIR /var/www

CMD ["/usr/local/bin/start"]
