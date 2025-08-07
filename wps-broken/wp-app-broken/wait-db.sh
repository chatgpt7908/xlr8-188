#!/bin/sh
set -e

DB_HOST=${WORDPRESS_DB_HOST:-localhost}
DB_PORT=3306

echo "⏳ Waiting for MySQL to be available at $DB_HOST:$DB_PORT..."
for i in $(seq 1 20); do
    if nc -z "$DB_HOST" "$DB_PORT"; then
        echo "✅ MySQL is reachable!"
        break
    fi
    echo "⏳ Attempt $i: MySQL not reachable yet..."
    sleep 2
done

if ! nc -z "$DB_HOST" "$DB_PORT"; then
    echo "❌ Failed to connect to MySQL at $DB_HOST:$DB_PORT after 20 tries."
    exit 1
fi

echo "🔐 Verifying MySQL credentials..."
if ! mysql -h "$DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e ";" 2>/tmp/mysql_error; then
    echo "❌ Cannot reach database."
    ERROR=$(cat /tmp/mysql_error)
    if echo "$ERROR" | grep -q "Access denied"; then
        echo "🛑 Reason: Invalid username or password"
    elif echo "$ERROR" | grep -q "Unknown MySQL server host"; then
        echo "🛑 Reason: Host not found"
    else
        echo "🛑 Reason: $ERROR"
    fi
    exit 1
fi

echo "✅ Database credentials are valid."

# 🧠 Fallback to apache2-foreground if no CMD passed
if [ "$#" -eq 0 ]; then
    set -- apache2-foreground
fi

exec "$@"

