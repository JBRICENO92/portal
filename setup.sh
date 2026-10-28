#!/usr/bin/env bash
# setup.sh - Instalación y despliegue automatizado del Portal y Caddy en Linux / Raspberry Pi
set -euo pipefail

# Verificar permisos de root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Este script debe ejecutarse con permisos de administrador (sudo ./setup.sh)"
  exit 1
fi

echo "== [1/5] Instalando dependencias del sistema y repositorio oficial de Caddy =="
apt-get update
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl

if [ ! -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg ]; then
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update
fi

echo "== [2/5] Instalando Caddy =="
apt-get install -y caddy

echo "== [3/5] Preparando directorio web en /var/www/portal =="
mkdir -p /var/www/portal
cp -r site/* /var/www/portal/
chown -R caddy:caddy /var/www/portal
chmod -R 755 /var/www/portal

echo "== [4/5] Configurando Caddyfile =="
cp Caddyfile /etc/caddy/Caddyfile

echo "== [5/5] Iniciando y habilitando servicio Caddy =="
systemctl daemon-reload
systemctl enable --now caddy
systemctl reload caddy

echo ""
echo "=========================================================="
echo "¡Portal desplegado exitosamente!"
echo "Puedes acceder desde tu navegador en:"
echo "  https://$(hostname -I | awk '{print $1}')/"
echo "=========================================================="
