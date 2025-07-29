#!/bin/bash

# Define image names
REMOTE_IMAGE="quay.io/ysachin/ex188/nginx:acme"
LOCAL_TAG="oci-registry:5000/nginx:acme"

echo "📥 Pulling image from $REMOTE_IMAGE..."
if podman pull "$REMOTE_IMAGE"; then
  echo "✅ Successfully pulled image."
else
  echo "❌ Failed to pull image."
  exit 1
fi

echo "🔄 Tagging as $LOCAL_TAG..."
podman tag "$REMOTE_IMAGE" "$LOCAL_TAG"

echo "✅ Image is now tagged and ready."

