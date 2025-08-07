#!/bin/bash

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

