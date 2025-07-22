#!/bin/bash

CONTAINER_NAME="acme-demo-html"
EXPECTED_IMAGE="registry.ocp4.example.com:8443/acme/acme-demo-html:latest"
EXPECTED_PORT="8001->80/tcp"
EXPECTED_VOLUME="/home/desktop/workspaces/acme-demo-html/html:/html"

echo "🔍 Checking if container '$CONTAINER_NAME' is running..."
if ! podman ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
  echo "❌ Container '$CONTAINER_NAME' is not running."
  exit 1
else
  echo "✅ Container is running."
fi

echo "🔍 Checking image..."
IMAGE=$(podman inspect "$CONTAINER_NAME" --format '{{.Config.Image}}')
if [[ "$IMAGE" == "$EXPECTED_IMAGE" ]]; then
  echo "✅ Image is correct."
else
  echo "❌ Image mismatch. Found: $IMAGE"
  exit 1
fi

echo "🔍 Checking port mapping..."
PORTS=$(podman port "$CONTAINER_NAME" | grep 8001)
if [[ "$PORTS" == *"0.0.0.0:8001"* ]]; then
  echo "✅ Port mapping is correct."
else
  echo "❌ Port mapping mismatch. Found: $PORTS"
  exit 1
fi

echo "🔍 Checking volume mount..."
MOUNTS=$(podman inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{.Source}}:{{.Destination}}{{"\n"}}{{end}}' | grep -w "$EXPECTED_VOLUME")
if [[ -n "$MOUNTS" ]]; then
  echo "✅ Volume mount is correct."
else
  echo "❌ Volume mount mismatch. Found:"
  podman inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{.Source}}:{{.Destination}}{{"\n"}}{{end}}'
  exit 1
fi

echo "🔍 Verifying application response..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001)
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ Application is responding with HTTP 200 OK"
else
  echo "❌ Application did not respond properly. HTTP code: $HTTP_CODE"
  exit 1
fi

echo "🎉 All checks passed!"

