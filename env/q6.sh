#!/bin/bash

#!/bin/bash
set -e
# Broken image tags
broken_tags=("wp-backend-broken" "wp-app-broken" "wp-frontend-broken")

# Source and target
SOURCE_REGISTRY="quay.io/ysachin/ex188/acme"
TARGET_REGISTRY="oci-registry:5000/acme"

echo "🔁 Pulling, tagging, and cleaning up broken images..."

for tag in "${broken_tags[@]}"; do
  SOURCE_IMAGE="$SOURCE_REGISTRY:$tag"
  TARGET_IMAGE="$TARGET_REGISTRY:$tag"

  echo "📥 Pulling $SOURCE_IMAGE ..."
  podman pull docker://$SOURCE_IMAGE

  echo "🏷️ Tagging as $TARGET_IMAGE ..."
  podman tag $SOURCE_IMAGE $TARGET_IMAGE

  echo "🧹 Removing original tag $SOURCE_IMAGE ..."
  podman rmi $SOURCE_IMAGE
done

echo "✅ Done. All images re-tagged and cleaned up."


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
  oci-registry:5000/acme:wp-backend-broken

echo "🐳 Starting wp-app-broken (WordPress PHP)..."
podman run -d --name wp-app-broken \
  --network acme-troubles \
  -v acme-wp-app-ts:/var/www/html:Z \
  oci-registry:5000/acme:wp-app-broken

echo "🐳 Starting wp-frontend-broken (NGINX)..."
podman run -d --name wp-frontend-broken \
  --network acme-troubles \
  -p 8094:80 \
  oci-registry:5000/acme:wp-frontend-broken

echo "✅ All broken containers are up!"
echo
podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo
echo "🔍 Visit http://localhost:8094 — the site will be broken until you fix the configs."

