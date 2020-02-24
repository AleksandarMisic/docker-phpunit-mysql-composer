FROM php:7.2-cli-stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget lsb-release gnupg2
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb
RUN dpkg -i mysql-apt-config*

RUN apt-get update

RUN apt-get install -y \
    mysql-server \
    libmagickwand-dev \
    git \
    libfreetype6-dev \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    --no-install-recommends --allow-unauthenticated \
  && apt-get clean

CMD mysqld

WORKDIR /var/app

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
&& php -r "unlink('composer-setup.php');" \

RUN composer selfupdate && \
    composer require "phpunit/phpunit:~7.0" --prefer-source --no-interaction && \
ln -s /tmp/vendor/bin/phpunit /usr/bin/phpunit

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/  --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install pdo_mysql bcmath gd
RUN pecl install imagick
RUN docker-php-ext-enable imagick

ENTRYPOINT mysqld --user=root

