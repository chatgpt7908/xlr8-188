#!/bin/bash

echo "🔍 Checking if container 'acme-demo-nginx' is running..."
if ! podman ps --format '{{.Names}}' | grep -q '^acme-demo-nginx$'; then
  echo "❌ Container 'acme-demo-nginx' is not running."
  exit 1
else
  echo "✅ Container is running."
fi

echo "🔍 Checking container image..."
image=$(podman inspect acme-demo-nginx --format '{{.Config.Image}}')
if [[ "$image" == "registry.ocp4.example.com:5000/nginx" || "$image" == "registry.ocp4.example.com:5000/nginx:latest" ]]; then
  echo "✅ Image is correct."
else
  echo "❌ Image mismatch. Found: $image"
  exit 1
fi

echo "🔍 Checking volume mount for /html..."
html_mount=$(podman inspect acme-demo-nginx --format '{{range .Mounts}}{{if eq .Destination "/html"}}{{.Source}}{{end}}{{end}}')
if [[ "$html_mount" == "/home/desktop/workspaces/acme-demo-db/nginx/html" ]]; then
  echo "✅ HTML mount is correct."
else
  echo "❌ HTML mount incorrect. Found: $html_mount"
  exit 1
fi

echo "🔍 Checking volume mount for /etc/nginx/default.conf..."
conf_mount=$(podman inspect acme-demo-nginx --format '{{range .Mounts}}{{if eq .Destination "/etc/nginx/default.conf"}}{{.Source}}{{end}}{{end}}')
if [[ "$conf_mount" == "/home/desktop/workspaces/acme/nginx-default.conf" ]]; then
  echo "✅ default.conf mount is correct."
else
  echo "❌ default.conf mount incorrect. Found: $conf_mount"
  exit 1
fi

echo "✅✅ All validations passed for acme-demo-nginx container."

