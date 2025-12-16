# ==============================
# PHP + Composer Stage
# ==============================
FROM php:8.1-fpm as php


RUN apt-get update && apt-get install -y \
git unzip curl libpq-dev libonig-dev libzip-dev \
&& docker-php-ext-install pdo pdo_mysql bcmath


# Redis extension
RUN pecl install redis && docker-php-ext-enable redis


# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer


WORKDIR /var/www


COPY . .


RUN composer install --no-dev --optimize-autoloader --no-interaction


RUN chown -R www-data:www-data /var/www \
&& chmod -R 755 /var/www/storage /var/www/bootstrap/cache


# ==============================
# Node Build Stage
# ==============================
FROM node:18-alpine as node


WORKDIR /app
COPY . .


RUN npm install && npm run build


# ==============================
# Nginx + PHP Runtime
# ==============================
FROM nginx:alpine


# Copy Nginx config
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf


# Copy PHP app
COPY --from=php /var/www /var/www


# Copy built assets
COPY --from=node /app/public /var/www/public


# Entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


WORKDIR /var/www


EXPOSE 80


ENTRYPOINT ["/entrypoint.sh"]