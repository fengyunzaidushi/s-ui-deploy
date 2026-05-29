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
Panel: reverse proxy to http://s-ui:2095/app/
Subscription: reverse proxy to http://s-ui:2096/sub/
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

Create the shared Docker network once:

```bash
docker network create proxy
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
accpilot.online           -> acg-faka-nginx:80
www.accpilot.online       -> acg-faka-nginx:80
aa.sub2api.online/app/    -> s-ui:2095
aa.sub2api.online/sub/    -> s-ui:2096
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

Publish additional S-UI node ports by setting `SUI_NODE_PORTS`:

```bash
SUI_NODE_PORTS="31460:31460/tcp 31460:31460/udp 32000:32000/tcp" bash deploy.sh
```

## Upgrade

Run the script again:

```bash
bash deploy.sh
```

It keeps the existing `db` and `cert` directories.
