#!/bin/sh
# tests/npm/prueba.sh COMPILADOR — paquetes npm desde C-Forge (WebAssembly +
# Node.js): extern "npm:paquete" importa el paquete solo (CommonJS y ESM).
set -e
C=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
RAIZ=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d)
cp "$RAIZ/tests/npm/app.cfv" "$T/"
cd "$T"
CFORGE_STDLIB="$RAIZ/stdlib" "$C" build app.cfv --target wasm --release -o app >/dev/null
# Sin el paquete instalado: error claro.
if node app.mjs > sin.txt 2>&1; then exit 1; fi
grep -q 'falta el paquete npm "lodash" (npm install lodash)' sin.txt
npm init -y >/dev/null 2>&1
npm install --silent --no-audit --no-fund lodash@4 camelcase@8 >/dev/null 2>&1
[ "$(node app.mjs | tr '\n' ' ')" = "hola-mundo-desde-c-forge Vemoris fooBarBaz " ]
# TypeScript: bindgen lee el .d.ts del paquete y genera el módulo.
CFORGE_STDLIB="$RAIZ/stdlib" "$C" bindgen node_modules/camelcase/index.d.ts --lib camelcase -o camel.cfv >/dev/null
printf 'importar "camel"\nmostrar(camelcase("hola-mundo_desde c-forge"))\n' > ts.cfv
CFORGE_STDLIB="$RAIZ/stdlib" "$C" build ts.cfv --target wasm --release -o ts >/dev/null
[ "$(node ts.mjs)" = "holaMundoDesdeCForge" ]
cd /; rm -rf "$T"
echo "  ✓ npm: extern \"npm:…\" con lodash (CommonJS), camelcase (ESM) y su .d.ts con bindgen"
