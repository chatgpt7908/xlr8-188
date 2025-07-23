#!/bin/bash

# Create the required directories
sudo mkdir -p /home/desktop/workspaces/acme
sudo mkdir -p /home/desktop/workspaces/acme-demo-db/nginx/html
sudo chown -R student:student /home/desktop/workspaces/acme
sudo chown -R student:student  /home/desktop/workspaces/acme-demo-db/nginx/html

# Create correct full nginx-default.conf
cat <<EOF > /home/desktop/workspaces/acme/nginx-default.conf
worker_processes  1;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            root /html;
            index index.html;
        }
    }
}
EOF

# Create sample index.html file
cat <<EOF > /home/desktop/workspaces/acme-demo-db/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>ACME Demo Nginx</title>
</head>
<body>
    <h1>Welcome to ACME Nginx Demo Page</h1>
</body>
</html>
EOF

# Pull your custom image from Quay and tag it for exam
echo "📥 Pulling your image from quay.io/ysachin..."
podman pull quay.io/ysachin/ex188/demo-acme-nginx:latest

echo "🏷️ Tagging image as registry.ocp4.example.com:5000/nginx:latest..."
podman tag quay.io/ysachin/ex188/demo-acme-nginx:latest registry.ocp4.example.com:5000/nginx:latest

echo "✅ nginx-default.conf created at /home/desktop/workspaces/acme/nginx-default.conf"
echo "✅ index.html created at /home/desktop/workspaces/acme-demo-db/nginx/html/index.html"
echo "✅ Image pulled and tagged as registry.ocp4.example.com:5000/nginx:latest"

