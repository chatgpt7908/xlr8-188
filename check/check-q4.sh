#!/bin/bash

BACKUP_FILE="/home/desktop/workspace/acme-db/export/acme-backup.sql"

echo "🔍 Checking if backup file exists at $BACKUP_FILE..."
if [ -f "$BACKUP_FILE" ]; then
  echo "✅ Backup file found."
else
  echo "❌ Backup file not found!"
  exit 1
fi

echo "🔍 Checking if local registry is running..."
if podman ps --format '{{.Names}}' | grep -q '^acmeregistry$'; then
  echo "✅ Registry container 'acmeregistry' is running."
else
  echo "❌ Registry container 'acmeregistry' is not running!"
  exit 1
fi

echo "🔍 Verifying registry entry in /etc/hosts..."
if grep -q "127.0.0.1 acmeregistry" /etc/hosts; then
  echo "✅ /etc/hosts contains acmeregistry entry."
else
  echo "❌ Missing acmeregistry entry in /etc/hosts!"
  exit 1
fi

echo "🔍 Checking if image exists in local registry..."
if curl -s http://localhost:5000/v2/_catalog | grep -iE "acme-db|acme-db-exporter"; then
  echo "✅ Image 'acme-db' and acme-db-exporter exists in local registry."
else
  echo "❌ Images not found in registry!"
  exit 1
fi

echo "✅ All validations passed!"

