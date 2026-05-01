#!/bin/bash

set -e

# -----------------------------
# Default values
# -----------------------------
export BACKEND=${BACKEND:-backend:8000}
export SOCKETIO=${SOCKETIO:-websocket:9000}

export UPSTREAM_REAL_IP_ADDRESS=${UPSTREAM_REAL_IP_ADDRESS:-127.0.0.1}
export UPSTREAM_REAL_IP_HEADER=${UPSTREAM_REAL_IP_HEADER:-X-Forwarded-For}
export UPSTREAM_REAL_IP_RECURSIVE=${UPSTREAM_REAL_IP_RECURSIVE:-off}

export FRAPPE_SITE_NAME_HEADER=${FRAPPE_SITE_NAME_HEADER:-$host}

export PROXY_READ_TIMEOUT=${PROXY_READ_TIMEOUT:-120}
export CLIENT_MAX_BODY_SIZE=${CLIENT_MAX_BODY_SIZE:-50m}

echo "Backend: $BACKEND"
echo "SocketIO: $SOCKETIO"

# -----------------------------
# Generate nginx config safely
# -----------------------------
envsubst '
$BACKEND
$SOCKETIO
$UPSTREAM_REAL_IP_ADDRESS
$UPSTREAM_REAL_IP_HEADER
$UPSTREAM_REAL_IP_RECURSIVE
$FRAPPE_SITE_NAME_HEADER
$PROXY_READ_TIMEOUT
$CLIENT_MAX_BODY_SIZE
' < /templates/nginx/frappe.conf.template \
> /etc/nginx/conf.d/frappe.conf

# -----------------------------
# IMPORTANT: Enable Docker DNS
# -----------------------------
cat <<EOF >> /etc/nginx/nginx.conf

resolver 127.0.0.11 ipv6=off;
EOF

# -----------------------------
# Start nginx
# -----------------------------
exec nginx -g 'daemon off;'