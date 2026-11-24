# c-forge.org

Sitio oficial de C-Forge, desplegado en **Cloudflare Pages** desde este repo
(proyecto `c-forge`: directorio raíz `site`, comando `sh build.sh`, salida `dist`).

## Regla: todo lo que dice el sitio es verificable

| Lo que muestra | De dónde sale |
|---|---|
| Versión | `Makefile` (`VERSION`) |
| Tabla de estado | `capabilities.json` |
| Novedades | `site/data/releases.json` |
| Ejemplos y su salida | `site/ejemplos/*.cfv` y `*.salida` |

`site/verificar.sh` ejecuta cada ejemplo con `cforge` y compara su salida, y
comprueba que las páginas generadas estén al día. Corre en CI en cada cambio.

## Editar

1. Cambia `site/plantillas/*.html`, `site/assets/` o los ejemplos.
2. Si cambias un ejemplo, actualiza su salida:
   `(cd /tmp && ./cforge site/ejemplos/X.cfv) > site/ejemplos/X.salida`
3. Regenera: `./cforge site/generar.cfv`
4. Verifica: `sh site/verificar.sh ./cforge`

`build.sh` copia `install.sh` e `install.ps1` desde la raíz del repo: el
instalador del sitio y el del repo son siempre el mismo archivo.
