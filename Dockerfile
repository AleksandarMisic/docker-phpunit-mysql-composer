FROM phpunit/phpunit:5.1.0

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y mysql-server libmagickwand-dev --no-install-recommends \
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
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

RUN docker-php-ext-install pdo_mysql
RUN pecl install imagick
RUN docker-php-ext-enable imagick

ENTRYPOINT mysqld

