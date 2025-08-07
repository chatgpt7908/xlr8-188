#!/bin/bash

DB_HOST=${WORDPRESS_DB_HOST:-localhost}
DB_PORT=3306

# 🕒 Wait until the DB port is reachable
echo "⏳ Waiting for MySQL to be available at $DB_HOST:$DB_PORT..."
for i in {1..20}; do
    if nc -z "$DB_HOST" "$DB_PORT"; then
        echo "✅ MySQL is reachable!"
        break
    fi
    echo "⏳ Attempt $i: MySQL not reachable yet..."
    sleep 2
done

# Final check after loop
if ! nc -z "$DB_HOST" "$DB_PORT"; then
    echo "❌ Failed to connect to MySQL at $DB_HOST:$DB_PORT after 20 tries."
    exit 1
fi

# ✅ Now check credentials using mysql CLI
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
exit 0

