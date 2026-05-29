# S-UI Deploy

One-command Docker deployment for S-UI.

## Deploy

Run this on the server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fengyunzaidushi/s-ui-deploy/main/deploy.sh)
```

Or run from a cloned repository:

```bash
bash deploy.sh
```

The script creates:

```text
/opt/s-ui
/opt/s-ui/db
/opt/s-ui/cert
/opt/s-ui/docker-compose.yml
/usr/local/bin/s-ui
```

Then it runs:

```bash
docker compose up -d
```

## Access

```text
Panel: http://SERVER_IP:2095/app/
Subscription: http://SERVER_IP:2096/sub/
Default account: admin / admin
```

## Optional Caddy Proxy

When this server hosts multiple projects, let one Caddy instance own ports `80` and `443`.

Recommended layout:

```text
/opt/docker/
├── proxy/
│   ├── docker-compose.yml
│   └── Caddyfile
├── acg-faka/
└── s-ui/
```

This repository includes a Caddy template in `proxy/`:

```bash
mkdir -p /opt/docker/proxy
cp proxy/docker-compose.yml proxy/Caddyfile /opt/docker/proxy/
cd /opt/docker/proxy
docker compose up -d
```

The template routes:

```text
accpilot.online           -> 127.0.0.1:8080
www.accpilot.online       -> 127.0.0.1:8080
aa.sub2api.online/app/    -> 127.0.0.1:2095
aa.sub2api.online/sub/    -> 127.0.0.1:2096
```

Keep AnyTLS node ports, such as `31460`, outside Cloudflare proxy mode. Use DNS-only records for node domains.

## Helper Command

After deployment, use the host command:

```bash
s-ui status
s-ui logs
s-ui restart
s-ui admin -show
s-ui setting -show
```

## Optional Environment Variables

```bash
APP_DIR=/opt/s-ui IMAGE=ghcr.io/admin8800/s-ui CONTAINER_NAME=s-ui bash deploy.sh
```

## Upgrade

Run the script again:

```bash
bash deploy.sh
```

It keeps the existing `db` and `cert` directories.
