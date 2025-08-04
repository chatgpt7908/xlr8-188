#!/bin/bash

echo "📦 Checking images..."

for img in wp-backend wp-app wp-frontend; do
  if podman image exists oci-registry:5000/acme:$img; then
    echo "✅ Image oci-registry:5000/acme:$img exists."
  else
    echo "❌ Image oci-registry:5000/acme:$img not found!"
  fi
done

echo
echo "🔌 Checking network..."

if podman network inspect acme-wp &>/dev/null; then
  echo "✅ Network 'acme-wp' exists."
else
  echo "❌ Network 'acme-wp' not found!"
fi

echo
echo "🗂️  Checking volumes..."

for vol in acme-wp-backend acme-wp-app; do
  if podman volume inspect $vol &>/dev/null; then
    echo "✅ Volume '$vol' exists."
  else
    echo "❌ Volume '$vol' not found!"
  fi
done

echo
echo "🚀 Checking running containers..."

for c in wp-backend wp-app wp-frontend; do
  if podman ps --format '{{.Names}}' | grep -q $c; then
    echo "✅ Container '$c' is running."
  else
    echo "❌ Container '$c' is not running!"
  fi
done

echo
echo "🌐 Testing WordPress install page (http://localhost:8003/wp-admin/install.php)..."

resp=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8003/wp-admin/install.php)

if [ "$resp" = "200" ]; then
  echo "✅ WordPress install page is accessible (HTTP 200)."
else
  echo "❌ WordPress install page failed to load (HTTP $resp)."
fi

echo
echo "🏁 Validation complete."

