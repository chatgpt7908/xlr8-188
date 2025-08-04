#!/bin/bash

echo "🔄 Pulling images from quay.io..."

# Pull images from quay.io
podman pull quay.io/ysachin/ex188/acme:wp-backend
podman pull quay.io/ysachin/ex188/acme:wp-app
podman pull quay.io/ysachin/ex188/acme:wp-frontend

echo "🏷️ Tagging images to match exam registry..."

# Tag them as per question
podman tag quay.io/ysachin/ex188/acme:wp-backend   oci-registry:5000/acme:wp-backend
podman tag quay.io/ysachin/ex188/acme:wp-app       oci-registry:5000/acme:wp-app
podman tag quay.io/ysachin/ex188/acme:wp-frontend  oci-registry:5000/acme:wp-frontend

echo "✅ All images pulled and tagged:"
podman images | grep 'oci-registry\|quay.io/ysachin'

echo "🚀 Ready for deployment!"

