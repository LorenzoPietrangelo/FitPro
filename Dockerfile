FROM php:8.2-apache

# Estensioni PHP necessarie
RUN docker-php-ext-install pdo pdo_mysql

# Abilita mod_rewrite per il router
RUN a2enmod rewrite

# Permetti override in .htaccess
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Installa Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

# Cartella templates_c e cache scrivibili
RUN mkdir -p templates_c cache \
    && chown -R www-data:www-data templates_c cache

EXPOSE 80
