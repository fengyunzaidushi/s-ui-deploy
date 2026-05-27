#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/s-ui}"
IMAGE="${IMAGE:-ghcr.io/admin8800/s-ui}"
CONTAINER_NAME="${CONTAINER_NAME:-s-ui}"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs root privileges. Re-running with sudo..."
  exec sudo APP_DIR="$APP_DIR" IMAGE="$IMAGE" CONTAINER_NAME="$CONTAINER_NAME" bash "$0" "$@"
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker first, then run this script again."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is not available. Install docker compose first, then run this script again."
  exit 1
fi

mkdir -p "$APP_DIR/db" "$APP_DIR/cert"

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  s-ui:
    image: ${IMAGE}
    container_name: ${CONTAINER_NAME}
    hostname: s-ui
    network_mode: host
    volumes:
      - ./db:/app/db
      - ./cert:/app/cert
    tty: true
    restart: unless-stopped
    entrypoint: ./entrypoint.sh
EOF

cd "$APP_DIR"
docker compose pull
docker compose up -d

echo
echo "S-UI has been deployed."
echo "Compose file: $APP_DIR/docker-compose.yml"
echo "Panel: http://SERVER_IP:2095/app/"
echo "Subscription: http://SERVER_IP:2096/sub/"
echo "Default account: admin / admin"
