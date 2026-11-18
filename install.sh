#!/bin/sh
# ============================================================================
# Instalador oficial de C-Forge — https://c-forge.org
#
#   curl -fsSL https://c-forge.org/install.sh | sh
#
# Variables opcionales:
#   CFORGE_VERSION=3.7.3   instala una versión concreta (por defecto: la última)
#   CFORGE_PREFIX=$HOME/.local   carpeta de instalación (por defecto: /usr/local)
#   CFORGE_FROM_SOURCE=1   compila desde el código fuente en vez de bajar binario
# ============================================================================
set -eu

REPO="VemorisSoftware/C-Forge"
GITHUB="https://github.com/${REPO}"

if [ -t 1 ]; then
  B='\033[1m'; G='\033[0;32m'; R='\033[0;31m'; O='\033[0;33m'; N='\033[0m'
else
  B=''; G=''; R=''; O=''; N=''
fi
info()  { printf "${B}[C-Forge]${N} %s\n" "$1"; }
ok()    { printf "${G}[C-Forge]${N} %s\n" "$1"; }
warn()  { printf "${O}[C-Forge]${N} %s\n" "$1"; }
fail()  { printf "${R}[error]${N} %s\n" "$1" >&2; exit 1; }
tiene() { command -v "$1" >/dev/null 2>&1; }

descargar() { # url destino
  if tiene curl; then curl -fsSL --retry 3 "$1" -o "$2"
  elif tiene wget; then wget -q "$1" -O "$2"
  else fail "se necesita curl o wget"; fi
}

# ── Versión ────────────────────────────────────────────────────────────────
VERSION="${CFORGE_VERSION:-}"
if [ -z "$VERSION" ]; then
  # La redirección de /releases/latest no consume el límite de la API.
  if tiene curl; then
    VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "${GITHUB}/releases/latest" 2>/dev/null \
      | sed -n 's#.*/tag/v\{0,1\}\([0-9][0-9.]*\)$#\1#p')
  fi
  [ -n "$VERSION" ] || fail "no se pudo detectar la última versión; usa CFORGE_VERSION=3.7.3"
fi
VERSION="${VERSION#v}"

# ── Plataforma ─────────────────────────────────────────────────────────────
OS=$(uname -s); ARCH=$(uname -m)
PAQUETE=""
case "$OS-$ARCH" in
  Linux-x86_64|Linux-amd64)  PAQUETE="cforge-${VERSION}-linux-x64" ;;
  Linux-aarch64|Linux-arm64) PAQUETE="cforge-${VERSION}-linux-arm64" ;;
  Darwin-arm64)              PAQUETE="cforge-${VERSION}-macos-arm64" ;;
  Darwin-x86_64)             PAQUETE="cforge-${VERSION}-macos-x64" ;;
  *) fail "sistema no soportado: ${OS} ${ARCH}. En Windows: irm https://c-forge.org/install.ps1 | iex" ;;
esac
[ "${CFORGE_FROM_SOURCE:-0}" = "1" ] && PAQUETE=""

# ── Destino ────────────────────────────────────────────────────────────────
PREFIX="${CFORGE_PREFIX:-/usr/local}"
SUDO=""
if [ -z "${CFORGE_PREFIX:-}" ]; then
  if [ ! -w "$PREFIX" ] || { [ -d "$PREFIX/bin" ] && [ ! -w "$PREFIX/bin" ]; }; then
    if tiene sudo; then SUDO="sudo"; info "se pedirá tu contraseña (sudo) para instalar en ${PREFIX}"
    else PREFIX="$HOME/.local"; fi
  fi
fi
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/cforge"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

info "instalando C-Forge v${VERSION} para ${OS} ${ARCH}"

if [ -n "$PAQUETE" ]; then
  # ── Binario oficial ──────────────────────────────────────────────────────
  BASE="${GITHUB}/releases/download/v${VERSION}"
  info "descargando ${PAQUETE}.tar.gz"
  descargar "${BASE}/${PAQUETE}.tar.gz" "$TMP/${PAQUETE}.tar.gz" \
    || fail "no se pudo descargar ${BASE}/${PAQUETE}.tar.gz"
  if descargar "${BASE}/SHA256SUMS" "$TMP/SHA256SUMS" 2>/dev/null; then
    ESPERADO=$(grep " ${PAQUETE}.tar.gz\$" "$TMP/SHA256SUMS" | cut -d' ' -f1 || true)
    if [ -n "$ESPERADO" ]; then
      if tiene sha256sum; then REAL=$(sha256sum "$TMP/${PAQUETE}.tar.gz" | cut -d' ' -f1)
      else REAL=$(shasum -a 256 "$TMP/${PAQUETE}.tar.gz" | cut -d' ' -f1); fi
      [ "$ESPERADO" = "$REAL" ] || fail "la suma SHA-256 no coincide; descarga corrupta"
      ok "SHA-256 verificado"
    fi
  fi
  tar -xzf "$TMP/${PAQUETE}.tar.gz" -C "$TMP"
  ORIGEN="$TMP/${PAQUETE}"
  [ -x "$ORIGEN/cforge" ] || fail "el paquete no contiene el binario cforge"
elif [ "$OS" = "Linux" ] && { [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; }; then
  # ── Desde el código fuente: la semilla compila cforge (sin C++) ─────────
  tiene make || fail "se necesita make"
  info "descargando código fuente v${VERSION}"
  descargar "${GITHUB}/archive/refs/tags/v${VERSION}.tar.gz" "$TMP/src.tar.gz" \
    || fail "no existe la versión v${VERSION}"
  tar -xzf "$TMP/src.tar.gz" -C "$TMP"
  ORIGEN=$(find "$TMP" -maxdepth 1 -type d -name 'C-Forge-*' | head -1)
  [ -f "$ORIGEN/bootstrap/semilla/cforge-linux-x64" ] || fail "esta versión no trae la semilla nativa"
  info "compilando cforge con la semilla (C-Forge se compila a sí mismo)"
  (cd "$ORIGEN" && make build >/dev/null) || fail "la compilación falló"
else
  fail "no hay binario para ${OS} ${ARCH}"
fi

# ── Instalar ───────────────────────────────────────────────────────────────
$SUDO mkdir -p "$BIN_DIR" "$LIB_DIR"
$SUDO rm -rf "$LIB_DIR/stdlib"
$SUDO cp -R "$ORIGEN/stdlib" "$LIB_DIR/stdlib"
$SUDO cp "$ORIGEN/cforge" "$BIN_DIR/cforge"
$SUDO chmod 755 "$BIN_DIR/cforge"
$SUDO ln -sf cforge "$BIN_DIR/c-forge"
if [ "$OS" = "Darwin" ]; then
  # Quita la cuarentena de Gatekeeper del binario descargado.
  $SUDO xattr -d com.apple.quarantine "$BIN_DIR/cforge" 2>/dev/null || true
fi

"$BIN_DIR/cforge" --version >/dev/null 2>&1 || fail "el binario instalado no arranca"

printf "\n"
ok "$("$BIN_DIR/cforge" --version | head -1) instalado en ${BIN_DIR}/cforge"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "agrega ${BIN_DIR} a tu PATH:  export PATH=\"${BIN_DIR}:\$PATH\"" ;;
esac
printf "\n  Prueba:\n    echo 'mostrar(\"Hola, mundo\")' > hola.cfv\n    cforge hola.cfv\n\n"
