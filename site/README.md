# c-forge.org

Sitio oficial de C-Forge, desplegado en **Cloudflare Pages** desde este repo.

| Proyecto Pages | Directorio raíz | Comando de build | Salida | Dominio |
|---|---|---|---|---|
| `c-forge` | `site` | `sh build.sh` | `dist` | `c-forge.org` |
| `c-forge-panel` | `site/panel` | *(ninguno)* | `.` | `panel.c-forge.org` |

`build.sh` copia `install.sh` e `install.ps1` desde la raíz del repo: el
instalador del sitio y el del repo son siempre el mismo archivo.

Los binarios **no** se alojan en el sitio: `data/releases.json` apunta a
GitHub Releases.

En Cloudflare, `/install.sh`, `/install.ps1` y `/data/*` no deben pasar por
desafíos anti-bots (Bot Fight Mode / Under Attack): `curl` e `irm` no pueden
resolverlos.
