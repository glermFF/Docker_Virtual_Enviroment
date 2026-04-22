FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli gd \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN git clone --depth=1 https://github.com/digininja/DVWA.git /var/www/html/dvwa \
    && cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php \
    && sed -i "s/'db_server' => '127.0.0.1'/'db_server' => 'dvwa-db'/" /var/www/html/dvwa/config/config.inc.php \
    && sed -i "s/'db_user' => 'root'/'db_user' => 'dvwa'/" /var/www/html/dvwa/config/config.inc.php \
    && sed -i "s/'db_password' => 'p@ssw0rd'/'db_password' => 'dvwa'/" /var/www/html/dvwa/config/config.inc.php \
    && sed -i "s/'db_database' => 'dvwa'/'db_database' => 'dvwa'/" /var/www/html/dvwa/config/config.inc.php \
    && chown -R www-data:www-data /var/www/html/dvwa \
    && chmod -R 775 /var/www/html/dvwa/hackable/uploads \
    && chmod -R 775 /var/www/html/dvwa/external/phpids/0.6/lib/IDS/tmp

RUN printf "%s\n" \
    "allow_url_include = On" \
    "allow_url_fopen = On" \
    "display_errors = On" \
    "log_errors = Off" \
    > /usr/local/etc/php/conf.d/dvwa.ini

RUN printf "%s\n" \
    "<VirtualHost *:80>" \
    "    DocumentRoot /var/www/html/dvwa" \
    "    <Directory /var/www/html/dvwa>" \
    "        AllowOverride All" \
    "        Require all granted" \
    "    </Directory>" \
    "</VirtualHost>" \
    > /etc/apache2/sites-available/000-default.conf

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 \
  CMD curl -fsS http://localhost/login.php || exit 1
