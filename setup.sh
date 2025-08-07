#!/bin/bash
set -e

echo "🔧 Cleaning up any existing broken containers/network/volumes..."
podman rm -f wp-backend-broken wp-app-broken wp-frontend-broken 2>/dev/null || true
podman network rm acme-troubles 2>/dev/null || true
podman volume rm acme-wp-backend-ts acme-wp-app-ts 2>/dev/null || true

echo "💾 Creating volumes..."
podman volume create acme-wp-backend-ts
podman volume create acme-wp-app-ts

echo "🌐 Creating network..."
podman network create acme-troubles

echo "🐳 Starting wp-backend-broken (MariaDB)..."
podman run -d --name wp-backend-broken \
  --network acme-troubles \
  -v acme-wp-backend-ts:/var/lib/mysql:Z \
  localhost/wp-backend-broken

echo "🐳 Starting wp-app-broken (WordPress PHP)..."
podman run -d --name wp-app-broken \
  --network acme-troubles \
  -v acme-wp-app-ts:/var/www/html:Z \
  localhost/wp-app-broken

echo "🐳 Starting wp-frontend-broken (NGINX)..."
podman run -d --name wp-frontend-broken \
  --network acme-troubles \
  -p 8094:80 \
  localhost/wp-frontend-broken

echo "✅ All broken containers are up!"
echo
podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo
echo "🔍 Visit http://localhost:8094 — the site will be broken until you fix the configs."

