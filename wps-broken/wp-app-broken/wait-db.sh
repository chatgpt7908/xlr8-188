#!/bin/sh
set -e

echo "⏳ Waiting for database at $WORDPRESS_DB_HOST..."

# Test: Can resolve host?
if ! getent hosts "$WORDPRESS_DB_HOST" >/dev/null; then
  echo "❌ ERROR: Cannot resolve host '$WORDPRESS_DB_HOST'"
  exit 1
fi

# Test: Can connect to host:port?
if ! nc -z -v -w5 "$WORDPRESS_DB_HOST" 3306 2>&1; then
  echo "❌ ERROR: Cannot connect to '$WORDPRESS_DB_HOST:3306'. DB might be down or unreachable."
  exit 1
fi

# Test: Can authenticate?
if ! mysqladmin ping \
     -h "$WORDPRESS_DB_HOST" \
     -u "$WORDPRESS_DB_USER" \
     -p"$WORDPRESS_DB_PASSWORD" \
     --silent; then
  echo "❌ ERROR: Connected, but authentication failed. Check WORDPRESS_DB_USER or WORDPRESS_DB_PASSWORD."
  exit 1
fi

echo "✅ Database is up – launching Apache."
exec "$@"

