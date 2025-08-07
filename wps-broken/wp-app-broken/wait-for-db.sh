#!/bin/sh
set -e

echo "⏳ Waiting for database at $WORDPRESS_DB_HOST..."
if ! mysqladmin ping \
     -h "$WORDPRESS_DB_HOST" \
     -u "$WORDPRESS_DB_USER" \
     -p"$WORDPRESS_DB_PASSWORD" \
     --silent; then
  echo "❌ Cannot reach database, exiting."
  exit 1
fi

echo "✅ Database is up – launching Apache."
exec "$@"

