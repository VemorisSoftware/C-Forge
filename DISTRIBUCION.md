# Distribución de C-Forge

C-Forge se distribuye como motor nativo más la biblioteca estándar `.cfv`. Los
paquetes actuales no deben incluir Python, JVM, .NET ni Node.

## Construcción local

```sh
make clean
make build
make check
make test
make release-check
make install-check
```

## Homebrew

La plantilla `packaging/homebrew/Formula/cforge.rb.template` instala el
binario oficial de cada plataforma (macOS ARM64 e Intel, Linux x64 y ARM64)
y copia `stdlib/*.cfv`. La fórmula publicada reemplaza `VERSION` y cada
`SHA256_*` con los valores de `SHA256SUMS` del release.

## Debian/Ubuntu

En un anfitrión Debian con `g++` y `dpkg-deb`:

```sh
packaging/debian/build-deb.sh 2.6.0 amd64
```

El paquete resultante contiene el binario y la biblioteca estándar; no declara
una dependencia de Python.

## Windows

GitHub Actions compila `cforge.exe` y publica `cforge-VERSION-windows-x64.zip`
(ejecutable + `stdlib`) al crear un tag.

### WinGet

Paquete `VemorisSoftware.CForgeLang` (`winget install VemorisSoftware.CForgeLang`).
Tras publicar una release:

```sh
sh packaging/winget/generar.sh VERSION       # → dist-winget/manifests/v/VemorisSoftware/CForgeLang/VERSION/
```

El script toma el SHA256 del zip de `SHA256SUMS`. Los manifiestos se copian al
fork `VemorisSoftware/winget-pkgs` y se envían como PR a `microsoft/winget-pkgs`.
WinGet instala el zip como portable y deja un enlace simbólico en `Links`;
`cforge.exe` sigue ese enlace para hallar su `stdlib` (desde 5.0.0; el CI de
Windows lo prueba). El primer envío (3.7.0, PR #414662) se cerró y tenía la
licencia y las URL equivocadas.

## Límite de soporte

Que exista un flujo de empaquetado no equivale a soporte certificado. Consulta
`docs/PLATFORM-VALIDATION.md` para el estado real de cada plataforma.
