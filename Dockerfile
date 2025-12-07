# Multi-stage build for Laravel application
# Stage 1: PHP dependencies builder
FROM composer:2.6 AS dependencies

WORKDIR /app

COPY composer.json composer.lock* ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --classmap-authoritative

# Stage 2: Node dependencies builder (for frontend assets)
FROM node:18-alpine AS node-builder

WORKDIR /app

COPY package.json package-lock.json* yarn.lock* ./

RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; else npm ci; fi

COPY . .

RUN npm run build || yarn build

# Stage 3: Production PHP runtime
FROM php:8.2-fpm-alpine AS runtime

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    curl \
    git \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    postgresql-client \
    mysql-client \
    supervisor \
    bash \
    dcron \
    vim \
    tzdata

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install \
    -j$(nproc) \
    gd \
    pdo_mysql \
    pdo_pgsql \
    zip \
    bcmath \
    opcache \
    exif

# Install additional useful extensions
RUN pecl install redis && \
    docker-php-ext-enable redis

# Set timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set working directory
WORKDIR /app

# Copy PHP configuration
COPY docker/php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/10-opcache.ini

# Copy Nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Copy Supervisor configuration
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy application files from builder stages
COPY --from=dependencies /app/vendor /app/vendor
COPY --from=node-builder /app/public /app/public
COPY --from=node-builder /app/node_modules /app/node_modules

COPY . .

# Create necessary directories
RUN mkdir -p \
    storage/logs \
    storage/app \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache && \
    chown -R www-data:www-data \
    storage \
    bootstrap/cache \
    .env* \
    app && \
    chmod -R 775 storage bootstrap/cache

# Generate optimized autoloader and cache config
RUN composer dumpautoload --optimize --no-dev && \
    php artisan optimize:clear || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Expose ports
EXPOSE 9000 80

# Entry point script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]