# syntax=docker/dockerfile:1.7

# Stage 1: Install PHP dependencies with Composer
FROM php:8.3-cli-alpine AS vendor
WORKDIR /app

RUN apk add --no-cache \
    git \
    icu-dev \
    libzip-dev \
    unzip \
    zip \
    && docker-php-ext-install \
    intl \
    zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --optimize-autoloader

# Stage 2: Build frontend assets
FROM node:20-alpine AS assets
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY resources ./resources
COPY public ./public
COPY vite.config.js tailwind.config.js postcss.config.js ./
RUN npm run build

# Stage 3: Production runtime
FROM php:8.3-fpm-alpine AS app
WORKDIR /var/www/html

# Install system packages and PHP extensions required by Laravel
RUN apk add --no-cache \
    bash \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install \
    bcmath \
    intl \
    mbstring \
    pdo \
    pdo_mysql \
    zip

# Copy application source
COPY . .

# Copy built vendor and assets from previous stages
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build

# Ensure writable directories for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

USER www-data
EXPOSE 9000

CMD ["php-fpm"]
