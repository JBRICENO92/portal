async function loadApps() {
  const container = document.getElementById('apps-container');
  try {
    const res = await fetch('apps.json');
    if (!res.ok) throw new Error('No se pudo cargar apps.json');
    const apps = await res.json();

    container.innerHTML = '';

    apps.forEach(app => {
      const card = document.createElement('div');
      card.className = 'card';
      card.id = `card-${app.id}`;
      card.innerHTML = `
        <div>
          <div class="card-top">
            <div class="card-icon">${app.icono || '⚡'}</div>
            <div class="status-badge checking" id="badge-${app.id}">
              <span class="indicator-dot"></span>
              <span class="status-text">Verificando...</span>
            </div>
          </div>
          <div class="card-content">
            <h2 class="card-title">${app.nombre}</h2>
            <p class="card-desc">${app.descripcion}</p>
          </div>
        </div>
        <div class="card-footer">
          <span class="port-meta">Interno :${app.puerto}</span>
          <a href="${app.ruta}" class="open-btn" target="_blank" rel="noopener">
            Abrir
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
          </a>
        </div>
      `;
      container.appendChild(card);

      checkHealth(app);
    });
  } catch (err) {
    container.innerHTML = `<div class="loading-state">Error al cargar las aplicaciones: ${err.message}</div>`;
  }
}

async function checkHealth(app) {
  const badge = document.getElementById(`badge-${app.id}`);
  if (!badge) return;

  const statusText = badge.querySelector('.status-text');

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3500);

    const res = await fetch(app.health, { signal: controller.signal });
    clearTimeout(timeoutId);

    if (res.ok) {
      badge.className = 'status-badge online';
      statusText.textContent = 'En línea';
    } else {
      badge.className = 'status-badge offline';
      statusText.textContent = 'Error ' + res.status;
    }
  } catch (err) {
    badge.className = 'status-badge offline';
    statusText.textContent = 'Fuera de línea';
  }
}

document.getElementById('refresh-status-btn')?.addEventListener('click', () => {
  loadApps();
});

// Cargar al iniciar
loadApps();

// Auto refresco de estado cada 30 segundos
setInterval(() => {
  fetch('apps.json')
    .then(r => r.json())
    .then(apps => apps.forEach(checkHealth))
    .catch(() => {});
}, 30000);
