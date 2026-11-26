#!/bin/sh
# ============================================================================
# Instalador oficial de C-Forge — https://c-forge.org
#
#   curl -fsSL https://c-forge.org/install.sh | sh
#
# Variables opcionales:
#   CFORGE_VERSION=5.0.0   instala una versión concreta (por defecto: la última)
#   CFORGE_PREFIX=$HOME/.local   carpeta de instalación (por defecto: /usr/local)
#   CFORGE_FROM_SOURCE=1   compila desde el código fuente en vez de bajar binario
#   CFORGE_SIMPLE=1        sin animaciones ni colores (también NO_COLOR=1)
# ============================================================================
set -eu

# Todo va dentro de main(): si la descarga de este script se corta a la
# mitad, sh no ejecuta un fragmento incompleto.
main() {

REPO="VemorisSoftware/cforge"
# CFORGE_GITHUB_URL solo sirve para probar el instalador con un servidor local.
GITHUB="${CFORGE_GITHUB_URL:-https://github.com/${REPO}}"

# ── Interfaz ───────────────────────────────────────────────────────────────
# Con terminal de verdad: Forge (la mascota) animado, colores y pasos con
# indicador de progreso. Sin terminal (CI, logs) o con NO_COLOR/CFORGE_SIMPLE:
# texto simple, igual que siempre.
ANIMAR=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${CFORGE_SIMPLE:-0}" != "1" ] && [ "${TERM:-dumb}" != "dumb" ]; then
  ANIMAR=1
fi
E=$(printf '\033')
if [ "$ANIMAR" = "1" ]; then
  case "${COLORTERM:-}" in
    truecolor|24bit) NARANJA="${E}[38;2;255;106;50m"; F_NAR="38;2;255;106;50"; B_NAR="48;2;255;106;50"
                     F_BLA="38;2;255;255;255"; B_BLA="48;2;255;255;255"; F_OSC="38;2;24;24;24"; B_OSC="48;2;24;24;24" ;;
    *)               NARANJA="${E}[38;5;202m"; F_NAR="38;5;202"; B_NAR="48;5;202"
                     F_BLA="38;5;231"; B_BLA="48;5;231"; F_OSC="38;5;234"; B_OSC="48;5;234" ;;
  esac
  B="${E}[1m"; G="${E}[32m"; R="${E}[31m"; O="${E}[33m"; D="${E}[2m"; N="${E}[0m"
  printf '%s' "${E}[?25l"
else
  NARANJA=''; B=''; G=''; R=''; O=''; D=''; N=''
fi

restaurar() { [ "$ANIMAR" = "1" ] && printf '%s' "${E}[?25h${E}[0m"; return 0; }

info()  { if [ "$ANIMAR" = "1" ]; then printf "  ${D}%s${N}\n" "$1"; else printf "[C-Forge] %s\n" "$1"; fi; }
ok()    { if [ "$ANIMAR" = "1" ]; then printf "  ${G}✓${N} %s\n" "$1"; else printf "[C-Forge] %s\n" "$1"; fi; }
warn()  { if [ "$ANIMAR" = "1" ]; then printf "  ${O}!${N} %s\n" "$1"; else printf "[C-Forge] %s\n" "$1"; fi; }
fail()  {
  if [ "$ANIMAR" = "1" ]; then printf "\r${E}[2K  ${R}✗ %s${N}\n" "$1" >&2; else printf "[error] %s\n" "$1" >&2; fi
  restaurar; exit 1
}
tiene() { command -v "$1" >/dev/null 2>&1; }

# Forge, la mascota, en medios bloques: O naranja, W blanco, D oscuro, . vacío.
forge_rejilla() {
  case "$1" in
    parpadeo) printf '%s\n' ".OOOOOOOOOOOO." "OOOOOOOOOOOOOO" "OOOOOOOOOOOOOO" "OOOOOOOOOOOOOO" "OOWWWWOOWWWWOO" "OOOOOOOOOOOOOO" "OOOOOOOOOOOOOO" "OOOODOOOODOOOO" "OOOOODDDDOOOOO" "OOOOOOOOOOOOOO" ".OOOOOOOOOOOO." ".............." ;;
    feliz)    printf '%s\n' ".OOOOOOOOOOOO." "OOOOOOOOOOOOOO" "OOOWWOOOOWWOOO" "OOWOOWOOWOOWOO" "OOOOOOOOOOOOOO" "OOOOOOOOOOOOOO" "OOODOOOOOODOOO" "OOOODOOOODOOOO" "OOOOODDDDOOOOO" "OOOOOOOOOOOOOO" ".OOOOOOOOOOOO." ".............." ;;
    izq)      printf '%s\n' ".OOOOOOOOOOOO." "OOOOOOOOOOOOOO" "OOWWWWOOWWWWOO" "OOWDDWOOWDDWOO" "OOWDDWOOWDDWOO" "OOWWWWOOWWWWOO" "OOOOOOOOOOOOOO" "OOOODOOOODOOOO" "OOOOODDDDOOOOO" "OOOOOOOOOOOOOO" ".OOOOOOOOOOOO." ".............." ;;
    der)      printf '%s\n' ".OOOOOOOOOOOO." "OOOOOOOOOOOOOO" "OOWWWWOOWWWWOO" "OOWWDDOOWWDDOO" "OOWWDDOOWWDDOO" "OOWWWWOOWWWWOO" "OOOOOOOOOOOOOO" "OOOODOOOODOOOO" "OOOOODDDDOOOOO" "OOOOOOOOOOOOOO" ".OOOOOOOOOOOO." ".............." ;;
    *)        printf '%s\n' ".OOOOOOOOOOOO." "OOOOOOOOOOOOOO" "OOWWWWOOWWWWOO" "OODDWWOODDWWOO" "OODDWWOODDWWOO" "OOWWWWOOWWWWOO" "OOOOOOOOOOOOOO" "OOOODOOOODOOOO" "OOOOODDDDOOOOO" "OOOOOOOOOOOOOO" ".OOOOOOOOOOOO." ".............." ;;
  esac
}

# Dibuja a Forge (6 líneas) con un texto al lado de cada línea.
forge() {  # forge CUADRO "línea1|línea2|…|línea6"
  forge_rejilla "$1" | awk -v e="$E" -v t="$2" \
    -v fo="$F_NAR" -v bo="$B_NAR" -v fw="$F_BLA" -v bw="$B_BLA" -v fd="$F_OSC" -v bd="$B_OSC" '
    function fg(c) { return c == "O" ? fo : (c == "W" ? fw : fd) }
    function bg(c) { return c == "O" ? bo : (c == "W" ? bw : bd) }
    { fila[NR] = $0 }
    END {
      split(t, txt, "|")
      for (y = 1; y < NR; y += 2) {
        a = fila[y]; b = fila[y + 1]; s = "  "
        for (x = 1; x <= length(a); x++) {
          ca = substr(a, x, 1); cb = substr(b, x, 1)
          if (ca == "." && cb == ".") s = s " "
          else if (ca == ".") s = s e "[" fg(cb) "m▄" e "[0m"
          else if (cb == ".") s = s e "[" fg(ca) "m▀" e "[0m"
          else s = s e "[" fg(ca) ";" bg(cb) "m▀" e "[0m"
        }
        printf "%s   %s\n", s, txt[(y + 1) / 2]
      }
    }'
}

subir() { printf '%s' "${E}[${1}A"; }   # sube el cursor N líneas

# Ejecuta un paso largo con un indicador animado; al terminar deja ✓ o ✗.
paso() {  # paso "Mensaje" "Mensaje al terminar" comando…
  msg=$1; hecho=$2; shift 2
  if [ "$ANIMAR" != "1" ]; then
    info "$msg"
    "$@" > "$TMP/paso.log" 2>&1 || { cat "$TMP/paso.log" >&2; return 1; }
    return 0
  fi
  "$@" > "$TMP/paso.log" 2>&1 &
  pid=$!
  i=0
  while kill -0 "$pid" 2>/dev/null; do
    case $((i % 10)) in
      0) c="⠋";; 1) c="⠙";; 2) c="⠹";; 3) c="⠸";; 4) c="⠼";; 5) c="⠴";; 6) c="⠦";; 7) c="⠧";; 8) c="⠇";; *) c="⠏";;
    esac
    printf "\r${E}[2K  ${NARANJA}%s${N} %s" "$c" "$msg"
    i=$((i + 1)); sleep 0.08
  done
  if wait "$pid"; then
    printf "\r${E}[2K  ${G}✓${N} %s\n" "$hecho"; return 0
  fi
  printf "\r${E}[2K  ${R}✗${N} %s\n" "$msg"
  sed 's/^/    /' "$TMP/paso.log" | tail -5 >&2
  return 1
}

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
  [ -n "$VERSION" ] || fail "no se pudo detectar la última versión; usa CFORGE_VERSION=5.0.0"
fi
VERSION="${VERSION#v}"
case "$VERSION" in
  ""|*[!0-9.]*) fail "versión inválida: ${VERSION} (ejemplo: CFORGE_VERSION=5.0.0)" ;;
esac

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
case "$OS" in Darwin) SISTEMA="macOS" ;; *) SISTEMA="$OS" ;; esac

# ── Bienvenida ─────────────────────────────────────────────────────────────
if [ "$ANIMAR" = "1" ]; then
  T1="|${B}${NARANJA}C-Forge${N} ${D}v${VERSION}${N}|Instalador oficial · ${SISTEMA} ${ARCH}|${D}c-forge.org · Vemoris Software${N}||"
  printf '\n'
  forge centro "$T1"; sleep 0.35
  for cuadro in izq centro der centro parpadeo centro; do
    subir 6; forge "$cuadro" "$T1"; sleep 0.18
  done
  printf '\n'
fi

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
trap 'rm -rf "$TMP"; restaurar' EXIT INT TERM

# sudo pide la contraseña antes de las animaciones, no en medio de ellas.
if [ -n "$SUDO" ] && [ "$ANIMAR" = "1" ]; then
  printf '%s' "${E}[?25h"; sudo -v || fail "se necesita sudo para instalar en ${PREFIX}"; printf '%s' "${E}[?25l"
fi

[ "$ANIMAR" = "1" ] || info "instalando C-Forge v${VERSION} para ${OS} ${ARCH}"

verificar_sha() {
  descargar "${BASE}/SHA256SUMS" "$TMP/SHA256SUMS" \
    || { echo "no se pudo descargar SHA256SUMS para verificar la descarga"; return 1; }
  ESPERADO=$(grep " ${PAQUETE}.tar.gz\$" "$TMP/SHA256SUMS" | cut -d' ' -f1 || true)
  [ -n "$ESPERADO" ] || { echo "SHA256SUMS no incluye ${PAQUETE}.tar.gz"; return 1; }
  if tiene sha256sum; then REAL=$(sha256sum "$TMP/${PAQUETE}.tar.gz" | cut -d' ' -f1)
  elif tiene shasum; then REAL=$(shasum -a 256 "$TMP/${PAQUETE}.tar.gz" | cut -d' ' -f1)
  else echo "se necesita sha256sum o shasum para verificar la descarga"; return 1; fi
  [ "$ESPERADO" = "$REAL" ] || { echo "la suma SHA-256 no coincide; descarga corrupta"; return 1; }
}

if [ -n "$PAQUETE" ]; then
  # ── Binario oficial ──────────────────────────────────────────────────────
  BASE="${GITHUB}/releases/download/v${VERSION}"
  paso "Descargando ${PAQUETE}" "Descargado ${PAQUETE}" descargar "${BASE}/${PAQUETE}.tar.gz" "$TMP/${PAQUETE}.tar.gz" \
    || fail "no se pudo descargar ${BASE}/${PAQUETE}.tar.gz"
  # La verificación es obligatoria: sin SHA256SUMS o sin la línea del
  # paquete no se instala nada.
  paso "Verificando la firma SHA-256" "SHA-256 verificado" verificar_sha \
    || fail "$(cat "$TMP/paso.log" 2>/dev/null | tail -1)"
  [ "$ANIMAR" = "1" ] || ok "SHA-256 verificado"
  tar -xzf "$TMP/${PAQUETE}.tar.gz" -C "$TMP"
  ORIGEN="$TMP/${PAQUETE}"
  [ -x "$ORIGEN/cforge" ] || fail "el paquete no contiene el binario cforge"
elif [ "$OS" = "Linux" ] && { [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; }; then
  # ── Desde el código fuente: la semilla compila cforge (sin C++) ─────────
  tiene make || fail "se necesita make"
  paso "Descargando el código fuente v${VERSION}" "Código fuente v${VERSION} descargado" \
    descargar "${GITHUB}/archive/refs/tags/v${VERSION}.tar.gz" "$TMP/src.tar.gz" \
    || fail "no existe la versión v${VERSION}"
  tar -xzf "$TMP/src.tar.gz" -C "$TMP"
  ORIGEN=$(find "$TMP" -maxdepth 1 -type d \( -name 'cforge-*' -o -name 'C-Forge-*' \) | head -1)
  [ -f "$ORIGEN/bootstrap/semilla/cforge-linux-x64" ] || fail "esta versión no trae la semilla nativa"
  compilar() { (cd "$ORIGEN" && make build >/dev/null); }
  paso "Forjando cforge con la semilla (C-Forge se compila a sí mismo)" "cforge forjado desde el código fuente" compilar \
    || fail "la compilación falló"
else
  fail "no hay binario para ${OS} ${ARCH}"
fi

# ── Instalar ───────────────────────────────────────────────────────────────
instalar() {
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
}
paso "Instalando en ${BIN_DIR}" "Instalado en ${BIN_DIR}" instalar || fail "no se pudo instalar en ${BIN_DIR}"
paso "Probando el compilador" "El compilador arranca" "$BIN_DIR/cforge" --version \
  || fail "el binario instalado no arranca"

VERSION_TXT=$("$BIN_DIR/cforge" --version | head -1)
EN_PATH=1
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) EN_PATH=0 ;; esac

if [ "$ANIMAR" != "1" ]; then
  printf "\n"
  ok "${VERSION_TXT} instalado en ${BIN_DIR}/cforge"
  [ "$EN_PATH" = "1" ] || warn "agrega ${BIN_DIR} a tu PATH:  export PATH=\"${BIN_DIR}:\$PATH\""
  printf "\n  Prueba:\n    echo 'mostrar(\"Hola, mundo\")' > hola.cfv\n    cforge hola.cfv\n\n"
  return 0
fi

# ── Final: Forge celebra ───────────────────────────────────────────────────
T2="|${B}${NARANJA}¡C-Forge está listo!${N}|${D}${VERSION_TXT}${N}|${D}${BIN_DIR}/cforge${N}||"
printf '\n'
forge feliz "$T2"; sleep 0.25
for cuadro in centro feliz parpadeo feliz; do
  subir 6; forge "$cuadro" "$T2"; sleep 0.2
done
printf '\n'
if [ "$EN_PATH" = "0" ]; then
  printf "  ${O}!${N} Agrega C-Forge a tu PATH:\n"
  printf "    ${B}export PATH=\"%s:\$PATH\"${N}\n\n" "$BIN_DIR"
fi
printf "  ${D}Empieza así:${N}\n"
printf "    ${NARANJA}❯${N} echo 'mostrar(\"Hola, mundo\")' > hola.cfv\n"
printf "    ${NARANJA}❯${N} cforge hola.cfv\n\n"
printf "  ${D}Crea un proyecto:${N} ${B}cforge init mi_app${N}   ${D}Ayuda:${N} ${B}cforge --help${N}\n\n"
restaurar
}

main "$@"
