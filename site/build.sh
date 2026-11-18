#!/bin/sh
# Build de c-forge.org para Cloudflare Pages.
# Configuración en Pages: directorio raíz "site", comando "sh build.sh",
# directorio de salida "dist". Las páginas ya vienen generadas y verificadas
# por CI (generar.py + verificar.sh); aquí solo se arma la carpeta publicada.
set -eu
cd "$(dirname "$0")"
rm -rf dist
mkdir -p dist
cp -R index.html aprende.html 404.html favicon.png _headers _redirects assets data dist/
# Los instaladores viven en la raíz del repo: una sola fuente de verdad.
cp ../install.sh ../install.ps1 dist/
echo "c-forge.org listo en site/dist"
