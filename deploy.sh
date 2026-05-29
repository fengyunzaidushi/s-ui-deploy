#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/s-ui}"
IMAGE="${IMAGE:-ghcr.io/admin8800/s-ui}"
CONTAINER_NAME="${CONTAINER_NAME:-s-ui}"
COMMAND_PATH="${COMMAND_PATH:-/usr/local/bin/s-ui}"
PROXY_NETWORK="${PROXY_NETWORK:-proxy}"
SUI_NODE_PORTS="${SUI_NODE_PORTS:-31460:31460/tcp 31460:31460/udp}"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs root privileges. Re-running with sudo..."
  exec sudo \
    APP_DIR="$APP_DIR" \
    IMAGE="$IMAGE" \
    CONTAINER_NAME="$CONTAINER_NAME" \
    COMMAND_PATH="$COMMAND_PATH" \
    PROXY_NETWORK="$PROXY_NETWORK" \
    SUI_NODE_PORTS="$SUI_NODE_PORTS" \
    bash "$0" "$@"
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

if ! docker network inspect "$PROXY_NETWORK" >/dev/null 2>&1; then
  docker network create "$PROXY_NETWORK" >/dev/null
fi

ports_yaml=""
for port_mapping in $SUI_NODE_PORTS; do
  ports_yaml="${ports_yaml}      - \"${port_mapping}\"
"
done

cat > "$APP_DIR/docker-compose.yml" <<EOF
services:
  s-ui:
    image: ${IMAGE}
    container_name: ${CONTAINER_NAME}
    hostname: s-ui
    networks:
      - ${PROXY_NETWORK}
    ports:
${ports_yaml}    expose:
      - "2095"
      - "2096"
    volumes:
      - ./db:/app/db
      - ./cert:/app/cert
    tty: true
    restart: unless-stopped
    entrypoint: ./entrypoint.sh

networks:
  ${PROXY_NETWORK}:
    external: true
EOF

cd "$APP_DIR"
docker compose pull
docker compose up -d

cat > "$COMMAND_PATH" <<EOF
#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$APP_DIR"
CONTAINER_NAME="$CONTAINER_NAME"

usage() {
  cat <<'USAGE'
S-UI Docker helper

Usage:
  s-ui admin [options]       Manage first admin credentials
  s-ui setting [options]     Manage panel/subscription settings
  s-ui uri                   Show panel URI
  s-ui migrate               Run database migration
  s-ui status                Show container status
  s-ui logs                  Follow container logs
  s-ui restart               Restart container
  s-ui start                 Start container
  s-ui stop                  Stop container

Examples:
  s-ui admin -show
  s-ui admin -username admin -password new-password
  s-ui setting -show
USAGE
}

if [ "\${1:-}" = "" ]; then
  usage
  exit 0
fi

case "\$1" in
  status)
    cd "\$APP_DIR"
    docker compose ps
    ;;
  logs)
    docker logs -f "\$CONTAINER_NAME"
    ;;
  restart|start|stop)
    cd "\$APP_DIR"
    docker compose "\$1" s-ui
    ;;
  admin|setting|uri|migrate)
    if [ -t 0 ]; then
      docker exec -it "\$CONTAINER_NAME" ./sui "\$@"
    else
      docker exec "\$CONTAINER_NAME" ./sui "\$@"
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac
EOF
chmod +x "$COMMAND_PATH"

echo
echo "S-UI has been deployed."
echo "Compose file: $APP_DIR/docker-compose.yml"
echo "Command: $COMMAND_PATH"
echo "Panel: reverse proxy to http://${CONTAINER_NAME}:2095/app/"
echo "Subscription: reverse proxy to http://${CONTAINER_NAME}:2096/sub/"
echo "Default account: admin / admin"
