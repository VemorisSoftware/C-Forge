#!/usr/bin/env bash
# build-deb.sh VERSION ARQUITECTURA BINARIO — paquete .deb de C-Forge.
# El binario (cforge para Linux x64 o ARM64) lo compila C-Forge mismo
# (make build / compilación cruzada); no se necesita C++.
set -euo pipefail

VERSION="${1:?versión}"
ARCH="${2:?arquitectura (amd64 | arm64)}"
BINARIO="${3:?ruta del binario cforge}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGE="$ROOT/dist/deb-root-$ARCH"
PACKAGE="$ROOT/dist/cforge_${VERSION}_${ARCH}.deb"

rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/lib/cforge/stdlib" "$STAGE/usr/bin"
install -m 0755 "$BINARIO" "$STAGE/usr/bin/cforge"
install -m 0644 "$ROOT"/stdlib/*.cfv "$STAGE/usr/lib/cforge/stdlib/"

cat > "$STAGE/DEBIAN/control" <<CONTROL
Package: cforge
Version: $VERSION
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: Vemoris Group <hola@vemorisgroup.com>
Homepage: https://c-forge.org
Recommends: git
Description: Lenguaje de programación C-Forge (100 % C-Forge)
 Compilador nativo autoalojado de C-Forge: genera ejecutables para Linux,
 Windows, macOS e iOS sin C++, libc ni enlazador externo.
CONTROL
dpkg-deb --root-owner-group --build "$STAGE" "$PACKAGE" >/dev/null
rm -rf "$STAGE"
echo "$PACKAGE"
