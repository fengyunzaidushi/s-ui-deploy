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
