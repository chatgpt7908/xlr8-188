#!/bin/bash

set -e

echo "📁 Creating required directory structure..."
sudo mkdir -p /home/desktop/workspaces/acme-demo-html/html
sudo  chown -R student:student  /home/desktop/workspaces/acme-demo-html/html
echo "📝 Creating sample index.html..."
echo "<h1>Hello from Acme Web App!</h1>" > /home/desktop/workspaces/acme-demo-html/html/index.html

echo "🐳 Pulling prebuilt image from Quay..."
podman pull quay.io/ysachin/ex188/aceme-demo-html:latest

echo "🔁 Retagging image as per internal registry requirement..."
podman tag quay.io/ysachin/ex188/aceme-demo-html:latest registry.ocp4.example.com:8443/acme/acme-demo-html:latest

echo "✅ Environment ready."
echo "📂 File path: /home/desktop/workspaces/acme-demo-html/html"
echo "📦 Local image: registry.ocp4.example.com:8443/acme/acme-demo-html:latest"

