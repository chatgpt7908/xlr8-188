#!/bin/bash

echo "📁 Creating directory structure..."
sudo mkdir -p /home/desktop/workspace/acme-db/sql
sudo mkdir -p /home/desktop/workspace/acme-db/scripts
sudo chown -R student:student /home/desktop

echo "📝 Creating dummy SQL file..."
sudo tee /home/desktop/workspace/acme-db/sql/acmeData.sql > /dev/null <<EOF
USE acme;
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  role VARCHAR(100) NOT NULL
);

INSERT INTO users (name, email, role) VALUES ('Sachin Yadav', 'sachin@example.com', 'Engineer');
INSERT INTO users (name, email, role) VALUES ('Abhishek Murkar', 'abhi@example.com', 'Engineer');
EOF

echo "📝 Creating exporter.sh script..."
sudo tee /home/desktop/workspace/acme-db/scripts/exporter.sh > /dev/null <<'EOF'
#!/bin/bash
echo "⏳ Exporting database..."
mysqldump -u root -p\$MARIADB_ROOT_PASSWORD \$MARIADB_DATABASE > /backup/acme-backup.sql
echo "✅ Export complete. File saved to /backup/acme-backup.sql"
EOF

sudo chmod +x /home/desktop/workspace/acme-db/scripts/exporter.sh

echo "🧱 Creating empty Containerfile templates..."
sudo touch /home/desktop/workspace/acme-db/Containerfile.acme-db
sudo touch /home/desktop/workspace/acme-db/Containerfile.acme-db-exporter

echo "📦 Starting local registry as 'acmeregistry'..."
podman run -d --name acmeregistry -p 5000:5000 --restart=always quay.io/ysachin/ex188/registry:2 2>/dev/null

echo "🔧 Adding registry name to /etc/hosts..."
if ! grep -q "acmeregistry" /etc/hosts; then
  echo "127.0.0.1 acmeregistry" | sudo tee -a /etc/hosts
fi

echo "🛠️  Configuring /etc/containers/registries.conf..."
sudo tee /etc/containers/registries.conf > /dev/null <<EOF
unqualified-search-registries = ["acmeregistry:5000", "registry.access.redhat.com", "registry.redhat.io", "docker.io"]

[[registry]]
location = "acmeregistry:5000"
insecure = true
EOF

echo "✅ Environment for Q4 is ready."

