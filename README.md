# Portal Central & Reverse Proxy 🌐⚡

Portal de bienvenida y servidor reverse proxy basado en **Caddy v2.11** para unificar y aislar aplicaciones locales (como PDFEditor o MIR) en una Raspberry Pi o servidor Linux doméstico.

---

## 🚀 Características

- **Landing Page Moderna:** Interfaz con tema oscuro, micro-animaciones y tarjetas dinámicas generadas desde `apps.json`.
- **Monitoreo en Tiempo Real:** Verifica periódicamente el estado (`/health`) de cada servicio y muestra un badge interactivo (🟢 *En línea* / 🔴 *Fuera de línea*).
- **Reverse Proxy Unificado:** Atiende todas las peticiones en el puerto **443 (HTTPS)** y las redirige internamente a servicios aislados en `127.0.0.1:<puerto>`.
- **Redirección HTTP → HTTPS:** Convierte automáticamente cualquier petición al puerto 80 en conexión segura HTTPS (código 308).
- **Límite de Subida Amplio:** Configurado con `max_size 1GB` para permitir transferencia de archivos pesados sin restricciones.

---

## 🛠️ Instalación y Configuración desde Cero

### Opción Rápida (Script automatizado)
En una Raspberry Pi o máquina Debian/Ubuntu recién instalada:
```bash
git clone git@github.com:JBRICENO92/portal.git
cd portal
chmod +x setup.sh
sudo ./setup.sh
```

El script se encargará de instalar Caddy desde su repositorio oficial, copiar la web a `/var/www/portal`, aplicar el `Caddyfile` y levantar el servicio en systemd.

---

### Opción Manual

1. **Instalar el repositorio oficial de Caddy:**
   ```bash
   sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt-get update && sudo apt-get install -y caddy
   ```

2. **Copiar los archivos estáticos a `/var/www/portal`:**
   ```bash
   sudo mkdir -p /var/www/portal
   sudo cp -r site/* /var/www/portal/
   sudo chown -R caddy:caddy /var/www/portal
   sudo chmod -R 755 /var/www/portal
   ```

3. **Copiar la configuración de Caddy:**
   ```bash
   sudo cp Caddyfile /etc/caddy/Caddyfile
   sudo systemctl reload caddy
   ```

---

## ➕ ¿Cómo agregar un nuevo proyecto al Portal?

Agregar una nueva aplicación (por ejemplo, un proyecto en el puerto 5003) se hace en **dos pasos sencillos**:

### 1. Registrar la tarjeta en `site/apps.json`
Añade una nueva entrada en el archivo:
```json
{
  "id": "mi-proyecto",
  "nombre": "Mi Proyecto Nuevo",
  "descripcion": "Descripción breve de la herramienta.",
  "ruta": "/nuevo/",
  "icono": "🚀",
  "puerto": 5003,
  "health": "/nuevo/health"
}
```

### 2. Añadir la ruta en `Caddyfile`
Agrega un bloque de reverse proxy dentro de `Caddyfile`:
```caddy
handle_path /nuevo/* {
    reverse_proxy 127.0.0.1:5003 {
        header_up X-Forwarded-Prefix /nuevo
        header_up X-Forwarded-Proto https
    }
}
```

Luego recarga Caddy con:
```bash
sudo systemctl reload caddy
```

---

## 🔒 Notas sobre el Certificado HTTPS (`tls internal`)

El `Caddyfile` utiliza `tls internal`, lo que significa que Caddy actúa como su propia Autoridad Certificadora local para emitir certificados HTTPS dentro de tu red local. Al entrar por primera vez desde un navegador nuevo, pulsa **Configuración Avanzada → Continuar**.
