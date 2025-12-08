#!/bin/sh
set -e

# Cache configuration, routes, and views if artisan exists (Laravel specific)
if [ -f "artisan" ]; then
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Start supervisord to manage processes (Nginx + PHP-FPM)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf