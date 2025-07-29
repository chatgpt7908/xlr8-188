#!/bin/bash

echo "📦 Making sure no container is using port 8080..."
if podman ps --format '{{.Names}} {{.Ports}}' | grep -q '8080->80'; then
  echo "ℹ️  Stopping existing container using port 8080..."
  RUNNING=$(podman ps --format '{{.Names}} {{.ID}} {{.Ports}}' | grep '8080->80' | awk '{print $1}')
  podman stop "$RUNNING" >/dev/null
fi

echo "🔍 Checking container acme-demo-runtime_1..."

if ! podman ps -a --format '{{.Names}}' | grep -q '^acme-demo-runtime_1$'; then
  echo "❌ acme-demo-runtime_1 container does not exist!"
  exit 1
fi

echo "ℹ️  Starting acme-demo-runtime_1..."
podman start acme-demo-runtime_1 >/dev/null
sleep 2

echo "🌐 Curl output (runtime_1):"
C1=$(curl -s http://localhost:8080)
echo "$C1"

if echo "$C1" | grep -q 'ACME_Container_1'; then
  echo "✅ Output correct for acme-demo-runtime_1"
else
  echo "❌ Output incorrect for acme-demo-runtime_1"
  exit 1
fi

echo
echo "🛑 Stopping acme-demo-runtime_1 and starting acme-demo-runtime_2..."
podman stop acme-demo-runtime_1 >/dev/null
podman rm -f acme-demo-runtime_2 >/dev/null 2>&1

podman run -d --name acme-demo-runtime_2 \
  -e WELCOME_MASSAGE="ACME_Container_2" \
  -p 8080:80 \
  oci-registry:5000/nginx:acme >/dev/null

sleep 2

echo "🌐 Curl output (runtime_2):"
C2=$(curl -s http://localhost:8080)
echo "$C2"

if echo "$C2" | grep -q 'ACME_Container_2'; then
  echo "✅ Output correct for acme-demo-runtime_2"
  echo
  echo "🎉 Validation PASSED"
else
  echo "❌ Output incorrect for acme-demo-runtime_2"
  exit 1
fi

