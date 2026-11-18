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

GitHub Actions compila `cforge.exe` con MSVC y publica el ejecutable al crear un
tag. El manifiesto WinGet es una plantilla y no debe enviarse hasta confirmar el
hash del artefacto y una ejecución física limpia en Windows x64.

## Límite de soporte

Que exista un flujo de empaquetado no equivale a soporte certificado. Consulta
`docs/PLATFORM-VALIDATION.md` para el estado real de cada plataforma.
