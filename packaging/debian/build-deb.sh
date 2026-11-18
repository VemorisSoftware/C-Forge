#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-2.6.0}"
ARCH="${2:-all}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGE="$ROOT/dist/deb-root"
PACKAGE="$ROOT/dist/cforge_${VERSION}_${ARCH}.deb"

rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/lib/cforge/stdlib" "$STAGE/usr/bin"
if [ "$ARCH" = "amd64" ] && [ -x "$ROOT/cforge-nativo" ]; then
  # cforge oficial: compilador nativo autoalojado; el intérprete C++ queda
  # como cforge-clasico para lo que el compilador nativo aún no cubre.
  install -m 0755 "$ROOT/cforge-nativo" "$STAGE/usr/bin/cforge"
  "${CXX:-g++}" -std=c++20 -O2 -I"$ROOT" -I"$ROOT/include" \
    "$ROOT/cforgev.cpp" -o "$STAGE/usr/bin/cforge-clasico" -pthread -ldl
else
  "${CXX:-g++}" -std=c++20 -O2 -I"$ROOT" -I"$ROOT/include" \
    "$ROOT/cforgev.cpp" -o "$STAGE/usr/bin/cforge" -pthread -ldl
fi
install -m 0644 "$ROOT"/stdlib/*.cfv "$STAGE/usr/lib/cforge/stdlib/"
ln -s cforge "$STAGE/usr/bin/cforgev"

cat > "$STAGE/DEBIAN/control" <<EOF
Package: cforge
Version: $VERSION
Section: devel
Priority: optional
Architecture: $ARCH
Maintainer: Vemoris Group <hola@vemorisgroup.com>
Homepage: https://github.com/VemorisSoftware/C-Forge
Description: Runtime estable del lenguaje C-Forge
 Ejecuta programas y pruebas .cfv sin Python, JVM, .NET ni Node.
EOF
dpkg-deb --root-owner-group --build "$STAGE" "$PACKAGE"
rm -rf "$STAGE"
echo "$PACKAGE"
