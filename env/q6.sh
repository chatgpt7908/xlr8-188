#!/bin/bash
# HARD 3-TIER TROUBLESHOOTING LAB
 
# Cleanup old resources
podman stop mysql-wp wordpress-app nginx-frontend
podman rm mysql-wp wordpress-app nginx-frontend
podman network rm wp-network
 
# Create network with DNS disabled (INTENTIONAL ISSUE)
podman network create wp-network --disable-dns
 
# MySQL Database (INTENTIONAL: Wrong root password, wrong port mapping)
podman run -d --name mysql-wp \
  --network wp-network \
  -e MYSQL_ROOT_PASSWORD=wrongpass \
  -e MYSQL_DATABASE=wpdb \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  -p 3308:3306 \
  -v mysql_data:/var/lib/mysql \
   quay.io/ysachin/ex188/acme:wp-backend-broken
 
# WordPress App (INTENTIONAL: Wrong DB host & password)
podman run -d --name wordpress-app \
  --network wp-network \
  -e WORDPRESS_DB_HOST=mysql-db:3306 \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wrongpass \
  -e WORDPRESS_DB_NAME=wpdb \ 
  -p 8081:80 \
  -v wp_data:/var/www/html \
   quay.io/ysachin/ex188/acme:wp-app-broken 
 
# NGINX Frontend (INTENTIONAL: Wrong proxy_pass host & bad conf)
cat <<'EOF' > nginx.conf
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://backend-prod:80;
 
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

 
podman run -d --name nginx-frontend \
  --network wp-network \
  -v wp_data:/usr/share/nginx/html \
  -v ./nginx.conf:/etc/nginx/nginx.conf:Z \
  -p 8080:80 \
  quay.io/ysachin/ex188/acme:wp-frontend-broken
  
