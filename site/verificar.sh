#!/bin/sh
# Verifica que todo lo que muestra c-forge.org sea cierto:
#   1. cada ejemplo de site/ejemplos se ejecuta y su salida coincide con .salida
#   2. las páginas generadas están al día con plantillas, ejemplos y datos
# Uso: sh site/verificar.sh [ruta/a/cforge]
set -eu
SITIO="$(cd "$(dirname "$0")" && pwd)"
CFORGE="${1:-$SITIO/../cforge}"
CFORGE="$(cd "$(dirname "$CFORGE")" && pwd)/$(basename "$CFORGE")"
export CFORGE_STDLIB="$SITIO/../stdlib"
fallos=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for ejemplo in "$SITIO"/ejemplos/*.cfv; do
  nombre=$(basename "$ejemplo" .cfv)
  (cd "$tmp" && "$CFORGE" "$ejemplo") > "$tmp/$nombre.real" 2>&1 || true
  if diff -u "$SITIO/ejemplos/$nombre.salida" "$tmp/$nombre.real" > "$tmp/$nombre.diff"; then
    echo "  OK   ejemplo $nombre"
  else
    echo "  FALLA ejemplo $nombre"; cat "$tmp/$nombre.diff"; fallos=$((fallos + 1))
  fi
done
python3 "$SITIO/generar.py" --check || fallos=$((fallos + 1))
[ "$fallos" -eq 0 ] && echo "  ✓ c-forge.org: ejemplos y páginas verificados" || { echo "  ✗ $fallos problema(s)"; exit 1; }
