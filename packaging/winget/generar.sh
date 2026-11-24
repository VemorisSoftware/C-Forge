#!/bin/sh
# Genera los manifiestos de WinGet (esquema 1.28.0, o $ESQUEMA) de una release publicada.
#
#   sh packaging/winget/generar.sh 5.0.0 [salida]
#
# Toma el SHA256 del zip de Windows de SHA256SUMS de la release (o de $SHA si
# está definido) y escribe salida/manifests/v/VemorisSoftware/CForgeLang/<versión>/,
# listo para un PR a microsoft/winget-pkgs desde el fork VemorisSoftware/winget-pkgs.
set -eu
VERSION="${1:?uso: generar.sh VERSION [salida]}"
SALIDA="${2:-dist-winget}"
ID=VemorisSoftware.CForgeLang
ZIP="cforge-$VERSION-windows-x64.zip"
BASE="https://github.com/VemorisSoftware/C-Forge/releases/download/v$VERSION"
if [ -z "${SHA:-}" ]; then
    SHA=$(curl -fsSL "$BASE/SHA256SUMS" | awk -v z="$ZIP" '$2 == z { print $1 }')
fi
[ -n "$SHA" ] || { echo "no se encontró el SHA256 de $ZIP" >&2; exit 1; }
SHA=$(echo "$SHA" | tr 'a-f' 'A-F')
DIR="$SALIDA/manifests/v/VemorisSoftware/CForgeLang/$VERSION"
mkdir -p "$DIR"
FECHA=$(date -u +%Y-%m-%d)
ESQUEMA="${ESQUEMA:-1.28.0}"

cat > "$DIR/$ID.yaml" <<FIN
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.version.$ESQUEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
DefaultLocale: es-CL
ManifestType: version
ManifestVersion: $ESQUEMA
FIN

cat > "$DIR/$ID.installer.yaml" <<FIN
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.installer.$ESQUEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
InstallerType: zip
NestedInstallerType: portable
NestedInstallerFiles:
  - RelativeFilePath: cforge-$VERSION-windows-x64\\cforge.exe
    PortableCommandAlias: cforge
ReleaseDate: $FECHA
Installers:
  - Architecture: x64
    InstallerUrl: $BASE/$ZIP
    InstallerSha256: $SHA
ManifestType: installer
ManifestVersion: $ESQUEMA
FIN

cat > "$DIR/$ID.locale.es-CL.yaml" <<FIN
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.defaultLocale.$ESQUEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
PackageLocale: es-CL
Publisher: Vemoris Group
PublisherUrl: https://c-forge.org
PublisherSupportUrl: https://github.com/VemorisSoftware/C-Forge/issues
PackageName: C-Forge
PackageUrl: https://c-forge.org
License: Uso libre (C-Forge License)
LicenseUrl: https://github.com/VemorisSoftware/C-Forge/blob/main/LICENSE
Copyright: Copyright (c) 2026 Vemoris Group S.A.
ShortDescription: Lenguaje de programación compilado con sintaxis en español e inglés
Description: C-Forge es un lenguaje compilado que se escribe en español o en inglés y genera ejecutables nativos para Windows, macOS, Linux y WebAssembly, con su biblioteca estándar incluida.
Moniker: cforge
Tags:
  - compilador
  - compiler
  - lenguaje-de-programacion
  - programming-language
  - cfv
ReleaseNotesUrl: https://github.com/VemorisSoftware/C-Forge/releases/tag/v$VERSION
ManifestType: defaultLocale
ManifestVersion: $ESQUEMA
FIN

cat > "$DIR/$ID.locale.en-US.yaml" <<FIN
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.locale.$ESQUEMA.schema.json
PackageIdentifier: $ID
PackageVersion: $VERSION
PackageLocale: en-US
Publisher: Vemoris Group
PublisherUrl: https://c-forge.org
PublisherSupportUrl: https://github.com/VemorisSoftware/C-Forge/issues
PackageName: C-Forge
PackageUrl: https://c-forge.org
License: Freeware (C-Forge License)
LicenseUrl: https://github.com/VemorisSoftware/C-Forge/blob/main/LICENSE
Copyright: Copyright (c) 2026 Vemoris Group S.A.
ShortDescription: Compiled programming language with Spanish and English syntax
Description: C-Forge is a compiled language you can write in Spanish or English. It builds native executables for Windows, macOS, Linux and WebAssembly and ships its standard library.
Tags:
  - compiler
  - programming-language
  - spanish
  - cfv
ReleaseNotesUrl: https://github.com/VemorisSoftware/C-Forge/releases/tag/v$VERSION
ManifestType: locale
ManifestVersion: $ESQUEMA
FIN

echo "✓ manifiestos de WinGet en $DIR"
