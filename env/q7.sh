#!/bin/bash
set -e

WORKDIR=~/DO188/labs/troubleshooting-lab
mkdir -p $WORKDIR
cd $WORKDIR

echo "🔹[1/6] Creating custom Podman network..."
podman network create troubleshooting-lab || true

########################
# 1. Create API Source #
########################
cat > api.py <<'EOF'
import sys
from flask import Flask, jsonify

app = Flask(__name__)
version = sys.argv[1] if len(sys.argv) > 1 else "v1"

@app.route(f"/api/{version}/quotes")
def quotes():
    return jsonify({"quote": f"Hello from {version} API!"})

if __name__ == "__main__":
    port = 8080 if version == "v1" else 8081
    app.run(host="0.0.0.0", port=port)
EOF

########################
# 2. API Dockerfile    #
########################
cat > Dockerfile-api <<'EOF'
FROM python:3.11-alpine
WORKDIR /app
COPY api.py /app/api.py
RUN pip install flask
ENTRYPOINT ["python", "api.py"]
EOF

echo "🔹[2/6] Building API containers..."
podman build -t quotes-api -f Dockerfile-api

# Run API v1 and v2
podman rm -f quotes-api-v1 quotes-api-v2 2>/dev/null || true
podman run -d --name quotes-api-v1 --net troubleshooting-lab quotes-api v1
podman run -d --name quotes-api-v2 --net troubleshooting-lab quotes-api v2

########################
# 3. Nginx UI Config   #
########################
cat > nginx.conf.template <<'EOF'
events {}
http {
    server {
        listen 8080;

        location /api/v1/quotes {
            proxy_pass http://quotes-api-v1:8080/api/v1/quotes;
        }

        location /api/v2/quotes {
            proxy_pass http://quotes-api-v2:8080/api/v2/quotes;
        }

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

cat > nginx-fixed.conf <<'EOF'
events {}
http {
    server {
        listen 8080;

        location /api/v1/quotes {
            proxy_pass http://quotes-api-v1:8080/api/v1/quotes;
        }

        location /api/v2/quotes {
            proxy_pass http://quotes-api-v2:8081/api/v2/quotes;
        }

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

########################
# 4. UI Entrypoint + Dockerfile #
########################
cat > docker-entrypoint.sh <<'EOF'
#!/bin/sh
set -e
if [ -z "$QUOTES_API_VERSION" ]; then
    echo "❌ ERROR: QUOTES_API_VERSION not set!"
    exit 1
fi
exec nginx -g "daemon off;"
EOF
chmod +x docker-entrypoint.sh

cat > Dockerfile-ui <<'EOF'
FROM nginx:alpine
ENV QUOTES_API_VERSION=""
COPY nginx.conf.template /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && echo "<h1>Quotes UI</h1>" > /usr/share/nginx/html/index.html
EXPOSE 8080
ENTRYPOINT ["/docker-entrypoint.sh"]
EOF

echo "🔹[3/6] Building Quotes UI image..."
podman build -t quotes-ui-versioning:1.0 -f Dockerfile-ui

########################
# 5. Run UI (Step 1 - ENV missing → Fail) #
########################
echo "🔹[4/6] Running UI WITHOUT env & network (expected to EXIT due to missing ENV)..."
podman rm -f quotes-ui 2>/dev/null || true
set +e
podman run -d --name quotes-ui -p 3000:8080 quotes-ui-versioning:1.0
sleep 3
podman logs quotes-ui || true
set -e
echo "✅ Step 1 done: ENV missing → container exited with ❌ error."

########################
# 6. Troubleshooting Steps Info #
########################
echo ""
echo "============ 🟢 TROUBLESHOOTING FLOW ============"
echo "1️⃣ First run exited because ENV was missing."
echo ""
echo "👉 Step 2: Run with ENV but NO network:"
echo "   podman rm -f quotes-ui"
echo "   podman run -d --name quotes-ui -p 3000:8080 -e QUOTES_API_VERSION=v2 quotes-ui-versioning:1.0"
echo "   ➜ podman logs quotes-ui   # You will see nginx DNS resolve error"
echo ""
echo "👉 Step 3: Run with network but wrong nginx config (still broken):"
echo "   podman rm -f quotes-ui"
echo "   podman run -d --name quotes-ui --network troubleshooting-lab -p 3000:8080 -e QUOTES_API_VERSION=v2 quotes-ui-versioning:1.0"
echo "   ➜ Access /api/v2 → 502 Bad Gateway"
echo ""
echo "👉 Step 4: Apply FIX by mounting correct nginx config:"
echo "   podman rm -f quotes-ui"
echo "   podman run -d --name quotes-ui --network troubleshooting-lab -p 3000:8080 -e QUOTES_API_VERSION=v2 -v $WORKDIR/nginx-fixed.conf:/etc/nginx/nginx.conf:Z quotes-ui-versioning:1.0"
echo "   ➜ Now /api/v2 works ✅"
echo "==================================================="

