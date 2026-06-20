FROM php:8.2-apache

# Dipendenze di sistema (unzip serve a Composer)
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Estensioni PHP necessarie
RUN docker-php-ext-install pdo pdo_mysql

ENV COMPOSER_ALLOW_SUPERUSER=1

# Abilita mod_rewrite, forza MPM prefork (richiesto da mod_php)
RUN a2dismod mpm_event mpm_worker 2>/dev/null || true && a2enmod mpm_prefork rewrite

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
