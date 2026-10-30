# Central Portal & Reverse Proxy 🌐⚡

Landing dashboard and reverse proxy server based on **Caddy v2** designed to unify, secure, and route local web applications (such as PDFEditor and MIR) on a Raspberry Pi or local Linux server.

---

## 🚀 Key Features

- **Modern Dashboard UI:** Dark obsidian theme, smooth micro-animations, and dynamic service cards populated from `apps.json`.
- **Real-Time Health Monitoring:** Automatically queries each backend service endpoint (`/health`) and displays dynamic status indicators (🟢 *Online* / 🔴 *Offline*).
- **Unified Reverse Proxy:** Terminates all external traffic on port **443 (HTTPS)** with `tls internal`, securely proxying requests to loopback backends on `127.0.0.1:<port>`.
- **Automatic HTTPS Redirection:** Seamlessly upgrades standard HTTP port 80 traffic to HTTPS.
- **High Upload Limit:** Configured with `max_size 1GB` to support large file uploads without gateway timeouts or proxy body truncation.

---

## 🛠️ Installation & Setup from Scratch

### Quick Setup (Automated Script)
On a fresh Raspberry Pi OS (Debian 12 Bookworm) or Ubuntu machine:

```bash
git clone git@github.com:JBRICENO92/portal.git
cd portal
chmod +x setup.sh
sudo ./setup.sh
```

The script automatically imports the official Caddy GPG keyring, installs Caddy, deploys static web files to `/var/www/portal`, applies `Caddyfile`, and starts the systemd service.

---

### Manual Setup

1. **Install Caddy from the official Debian/Ubuntu repository:**
   ```bash
   sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt-get update && sudo apt-get install -y caddy
   ```

2. **Deploy static dashboard files:**
   ```bash
   sudo mkdir -p /var/www/portal
   sudo cp -r site/* /var/www/portal/
   sudo chown -R caddy:caddy /var/www/portal
   sudo chmod -R 755 /var/www/portal
   ```

3. **Deploy Caddy configuration:**
   ```bash
   sudo cp Caddyfile /etc/caddy/Caddyfile
   sudo systemctl reload caddy
   ```

---

## ➕ How to Register a New Application

Adding a new local service (for example, a tool running on port 5003) takes **two simple steps**:

### 1. Add the Card Entry to `site/apps.json`
Add a new object in the `apps.json` array:
```json
{
  "id": "new-app",
  "nombre": "New Tool Name",
  "descripcion": "Brief summary of what this tool does.",
  "ruta": "/newapp/",
  "badge": "Active",
  "icono": "🚀",
  "puerto": 5003,
  "health": "/newapp/health"
}
```

### 2. Add the Route Block to `Caddyfile`
Add a reverse proxy handle block before the fallback static file server:
```caddy
handle_path /newapp/* {
    reverse_proxy 127.0.0.1:5003 {
        header_up X-Forwarded-Prefix /newapp
        header_up X-Forwarded-Proto https
    }
}
```

Apply the changes immediately:
```bash
sudo cp Caddyfile /etc/caddy/Caddyfile && sudo systemctl reload caddy
```

---

## 🔒 Internal HTTPS Certificate Notes (`tls internal`)

The `Caddyfile` is configured with `tls internal`. Caddy acts as its own local Certificate Authority (CA) to automatically issue trusted HTTPS certificates within your local network without requiring public domain registration.

When opening the dashboard for the first time on a new client browser, accept the local self-signed certificate (*Advanced → Proceed to site*).
