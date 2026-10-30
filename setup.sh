#!/usr/bin/env bash
# setup.sh - Automated installation and deployment of Portal & Caddy for Linux / Raspberry Pi
set -euo pipefail

# Verify root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] This script must be run with root privileges (sudo ./setup.sh)"
  exit 1
fi

echo "== [1/5] Installing system dependencies and official Caddy repository keyring =="
apt-get update
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl

if [ ! -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg ]; then
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update
fi

echo "== [2/5] Installing Caddy Web Server =="
apt-get install -y caddy

echo "== [3/5] Setting up web directory at /var/www/portal =="
mkdir -p /var/www/portal
cp -r site/* /var/www/portal/
chown -R caddy:caddy /var/www/portal
chmod -R 755 /var/www/portal

echo "== [4/5] Deploying Caddyfile configuration =="
cp Caddyfile /etc/caddy/Caddyfile

echo "== [5/5] Reloading and enabling Caddy service =="
systemctl daemon-reload
systemctl enable --now caddy
systemctl reload caddy

PRIMARY_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

echo ""
echo "=========================================================="
echo "Portal deployed successfully!"
echo "Access your portal via HTTPS in your web browser:"
echo "  https://${PRIMARY_IP}/"
echo "=========================================================="
