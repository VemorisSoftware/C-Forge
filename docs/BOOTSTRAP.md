# Arranque (bootstrap) de C-Forge

C-Forge es 100 % C-Forge: el compilador (`bootstrap/nativo/cforge_self.cfv`
y la capa de generación `gen*.cfv`), el runtime (`runtime/*.cfv`) y las
herramientas (CLI, paquetes, `fmt`, LSP, Xcode) están escritos en C-Forge.
No hay C++, libc ni enlazador externo en ninguna etapa.

## Raíz de confianza: la semilla

`bootstrap/semilla/cforge-linux-x64` es un `cforge` para Linux x64 generado
por el propio compilador. Con él:

| Etapa | Cómo | Resultado |
|---|---|---|
| s1 | semilla compila las fuentes | `cforge` nuevo (compilado por el anterior) |
| s2 | s1 compila las fuentes | `cforge` compilado por sí mismo |
| s3 | s2 compila las fuentes | idéntico a s2 byte por byte |

`make cforge-nativo` hace la cadena y comprueba `s2 = s3`. `make semilla`
actualiza la semilla tras cambiar el compilador y `make semilla-check`
comprueba que la semilla reproduce exactamente al compilador actual (y por
tanto a sí misma). La suma SHA-256 está en `cforge-linux-x64.sha256`.

## Todas las plataformas desde Linux

El mismo compilador genera, de forma cruzada y reproducible:

| Destino | Formato | Orden |
|---|---|---|
| `linux` | ELF x86-64 estático | `make build` |
| `linux-arm64` | ELF AArch64 estático | `make linux-arm64-cruzado` |
| `windows` | PE32+ x86-64 | `make windows-cruzado` |
| `macos` | Mach-O x86-64 | `make macos-cruzado` |
| `macos-arm64` | Mach-O ARM64 PIE con firma ad-hoc | `make macos-arm64-cruzado` |
| `ios-arm64`, `ios-sim-arm64` | biblioteca `.a` (Mach-O objeto) | `cforge build --lib` |

El CI compila `cforge` en Windows, macOS Intel y Apple Silicon reales y
comprueba que el resultado es idéntico byte por byte al compilado desde
Linux.

## Historia

Hasta la versión 3.7 el ejecutable distribuido era un intérprete en C++
(`cforgev.cpp`) y el compilador se arrancaba desde un Stage 0 en C++20. Ese
código se retiró del repositorio (sigue en el historial de git); la semilla
lo reemplaza como punto de partida.
