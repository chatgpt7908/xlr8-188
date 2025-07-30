#!/bin/bash
set -e

echo "🔍 [1/5] Checking running containers..."
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}" || true

echo "✅ Expected: quotes-api-v1, quotes-api-v2, quotes-ui must be Up and in troubleshooting-lab network"
echo ""

echo "🔍 [2/5] Checking logs for quotes-ui..."
if podman logs quotes-ui 2>&1 | grep -q "ERROR"; then
    echo "❌ Found ERROR in logs!"
    podman logs quotes-ui | grep "ERROR"
    exit 1
else
    echo "✅ No critical errors found in logs."
fi
echo ""

echo "🔍 [3/5] Testing API endpoints internally from quotes-ui..."
for v in v1 v2; do
    echo "➡️ Testing /api/$v/quotes ..."
    podman exec quotes-ui curl -s http://localhost:8080/api/$v/quotes || { echo "❌ Failed for $v"; exit 1; }
done
echo "✅ Internal API checks passed."
echo ""

echo "🔍 [4/5] Testing API endpoints externally on host..."
for v in v1 v2; do
    echo "➡️ curl -s http://localhost:3000/api/$v/quotes"
    curl -s http://localhost:3000/api/$v/quotes || { echo "❌ External check failed for $v"; exit 1; }
done
echo "✅ External API checks passed."
echo ""

echo "🔍 [5/5] Validating nginx configuration inside container..."
if podman exec quotes-ui grep -q "quotes-api-v2:8081" /etc/nginx/nginx.conf; then
    echo "✅ Nginx config correctly points to quotes-api-v2:8081"
else
    echo "❌ Nginx config does not have correct upstream for v2!"
    exit 1
fi

echo ""
echo "🎯 ALL VALIDATION CHECKS PASSED — Setup is Working Perfectly!"

