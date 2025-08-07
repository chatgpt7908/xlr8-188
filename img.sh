
##################################
# 🔨 Build All Images
##################################
cd wps-broken
echo "📦 Building wp-backend-broken..."
podman build -t localhost/wp-backend-broken ./wp-backend-broken

echo "📦 Building wp-app-broken..."
podman build -t localhost/wp-app-broken ./wp-app-broken -f app

echo "📦 Building wp-frontend-broken..."
podman build -t localhost/wp-frontend-broken ./wp-frontend-broken

echo "✅ All broken images built successfully!"

