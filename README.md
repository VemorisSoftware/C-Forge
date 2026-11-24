# C-Forge

![C-Forge](assets/cforgev-logo.svg)

**[c-forge.org](https://c-forge.org)** · [GitHub](https://github.com/VemorisSoftware/C-Forge) · [Releases](https://github.com/VemorisSoftware/C-Forge/releases)

C-Forge es un lenguaje de programación creado por Vemoris Group. Su objetivo es ofrecer una sintaxis clara, ejecución nativa y una biblioteca estándar escrita en el propio lenguaje.

> **C-Forge 5.0.0** — Lenguaje **100 % autoalojado** (compilador, runtime y biblioteca estándar escritos en C-Forge, sin C ni C++), verificado en cada cambio con **fuzzing y pruebas ofensivas** (entradas hostiles, bombas de compresión, ataques a HTTP/WebSocket y al gestor de paquetes) y **listo para producción**: el gate reproducible `make release-check` pasa en macOS (ARM64 e Intel), Linux (x64 y ARM64) y Windows x64. La criptografía está probada contra vectores oficiales, pero aún no tiene una auditoría externa independiente.

---

## Instalación rápida

### macOS y Linux (x64 y ARM64)

```sh
curl -fsSL https://c-forge.org/install.sh | sh
```

El instalador descarga el binario oficial desde GitHub Releases, verifica su
SHA-256 e instala `cforge` en `/usr/local/bin` (o en `~/.local/bin` si no hay
`sudo`). La biblioteca estándar queda en `<prefijo>/lib/cforge/stdlib` y
`cforge` la encuentra solo: **no hace falta configurar `CFORGE_STDLIB`**.

Hay binarios oficiales para macOS (Apple Silicon e Intel), Linux (x64 y ARM64)
y Windows x64. Todos los compila C-Forge mismo: no hay C++ en el proyecto.

Opciones:

```sh
curl -fsSL https://c-forge.org/install.sh | CFORGE_VERSION=5.0.0 sh   # versión fija
curl -fsSL https://c-forge.org/install.sh | CFORGE_PREFIX=$HOME/.local sh   # sin sudo
```

> **macOS:** el binario no está firmado con Apple Developer ID; el instalador
> quita la marca de cuarentena para que Gatekeeper no lo bloquee.

### Linux x64 (.deb)

```sh
wget https://github.com/VemorisSoftware/C-Forge/releases/download/v5.0.0/cforge_5.0.0_amd64.deb
sudo dpkg -i cforge_5.0.0_amd64.deb
```

### Windows x64

1. Descarga `cforge-5.0.0-windows-x64.zip` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/latest).
2. Extrae el ZIP en una carpeta fija, por ejemplo `C:\cforge`.
3. Añade esa carpeta al `PATH`. La `stdlib` incluida junto a `cforge.exe` se detecta sola.
4. Abre una nueva terminal y ejecuta `cforge --version`.

### Desinstalar

```sh
sudo rm -f /usr/local/bin/cforge /usr/local/bin/c-forge
sudo rm -rf /usr/local/lib/cforge
```

Con `.deb`: `sudo dpkg -r cforge`.

---

## Verificar la instalación

```sh
cforge --version
# → C-Forge 5.0.0

cforge --help
# → muestra todos los comandos disponibles

cforge doctor
# → diagnóstico del entorno
```

---

## Hello World

Crea un archivo `hola.cfv`:

```cfv
mostrar("Hola C-Forge")
```

Ejecútalo:

```sh
cforge hola.cfv
# → Hola C-Forge
```

O con el subcomando explícito:

```sh
cforge run hola.cfv
# → Hola C-Forge
```

---

## Ejemplo: funciones y clases

```cfv
funcion factorial(n: numero): numero {
    si (n <= 1) { retornar 1 }
    retornar n * factorial(n - 1)
}

clase Saludo {
    funcion constructor(nombre: texto): nulo {
        esto.nombre = nombre
    }
    funcion decir(): nulo {
        mostrar("Hola desde " + esto.nombre)
    }
}

mostrar(factorial(6))         // 720
sea s = nuevo Saludo("C-Forge")
s.decir()                     // Hola desde C-Forge
```

---

## CLI — comandos oficiales

| Comando | Función |
|---------|---------|
| `cforge archivo.cfv` | Ejecutar un programa |
| `cforge run archivo.cfv` | Ejecutar un programa (forma explícita) |
| `cforge repl` | Consola interactiva |
| `cforge check archivo.cfv` | Verificar sintaxis |
| `cforge test archivo.cfv` | Ejecutar pruebas `.cfv` |
| `cforge fmt archivo.cfv` | Validar formato sin modificar |
| `cforge new <nombre>` | Crear proyecto nuevo |
| `cforge init` | Inicializar proyecto en directorio actual |
| `cforge doctor` | Diagnosticar entorno |
| `cforge --version` | Mostrar versión |
| `cforge --help` | Mostrar ayuda |

---

## Extensión de Visual Studio Code

1. Descarga `c-forge-5.0.0.vsix` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/tag/v5.0.0).
2. En VS Code: **Extensions** (⇧⌘X) → **···** → **Install from VSIX…** → selecciona el archivo.
3. Los archivos `.cfv` tendrán resaltado de sintaxis, snippets y diagnósticos automáticos al guardar.

La extensión busca `cforge` en el PATH del sistema. Si el binario no está en el PATH, los comandos *Ejecutar* y *Comprobar* mostrarán un aviso.

---

## Crear un proyecto nuevo

```sh
cforge new mi-app
cd mi-app
cforge main.cfv
```

Esto genera:
```
mi-app/
  main.cfv        ← programa de entrada
  cforge.json     ← manifiesto del proyecto
  .gitignore
```

---

## Biblioteca estándar

Los módulos están en [`stdlib/`](stdlib/). Importa con:

```cfv
importar "matematica"
mostrar(piso(3.7))   // 3
```

Módulos disponibles: `matematica`, `lista`, `mapa`, `colecciones`, `algoritmos`, `texto`, `json`, `errores`, `fecha`, `numero`, `base64`, `regex`, `concurrencia`, `crypto`, `red` (HTTP/HTTPS, TCP, UDP), `tls`, `redis`, `db` y `sqlite`, `sdl`, `gl` (OpenGL 3.3), `apple` (macOS e iOS) y el resto de `stdlib/`: los 35 módulos cargan con el compilador nativo.

```cfv
importar "red"
sea r = http_solicitud("GET", "https://example.com/", {})
mostrar(r["estado"])                      // 200

importar "db"
sea db = db_conectar("datos.db")          // SQLite del sistema
db_consulta_p(db, "INSERT INTO notas (texto) VALUES (?)", ["hola"])
```

---

## Interoperabilidad con otros lenguajes

C-Forge usa librerías de otros lenguajes sin escribir código puente:

| Lenguaje | Cómo | Ejemplo |
|---|---|---|
| **C** | `cforge bindgen cabecera.h --lib nombre` genera el módulo desde la cabecera | `cforge bindgen /usr/include/zlib.h --lib z` |
| **C++** | `cforge bindgen geo.hpp --fuentes geo.cpp` y luego `importar "cpp:geo"`: clases, métodos, sobrecargas, `std::string`, `std::vector`, enums y excepciones (clang++) | `sea p = geo_Punto_nuevo_2(3, 4)` |
| **Rust** | `cforge bindgen rust:crate[@versión]` (crates.io o una ruta) y luego `importar "rust:crate"`: funciones, structs con sus métodos y campos, `Result`, `Option`, `Vec`, `String` y pánicos (cargo) | `cforge bindgen rust:strsim` → `strsim_levenshtein("casa", "cosa")` |
| **Zig** | Igual que C, si la librería expone una interfaz C (`export fn`) | — |
| **JavaScript / npm** | `extern "npm:paquete" funcion f(...)` con `--target wasm` | `extern "npm:lodash" funcion kebabCase(t: texto): texto` |
| **TypeScript** | `cforge bindgen paquete/index.d.ts --lib paquete` | `cforge bindgen node_modules/camelcase/index.d.ts --lib camelcase` |
| **Java** | `importar "java"`: la JVM corre dentro del programa (JNI) | `java_estatico("java.lang.Math", "max", "(II)I", [3, 9])` |
| **C# / .NET** | `importar "dotnet"`: métodos `[UnmanagedCallersOnly]` (hostfxr) | `dotnet_llamar(dotnet_funcion("Calc.dll", "Calc, Calc", "Sumar"), [40, 2])` |
| **HTML / CSS** | `importar "navegador"`: DOM, eventos, `nav_css`, `--html` | `nav_al_soltar(".tarjeta", ".columna", f)` |

Para C++ y Rust, `cforge bindgen` lee la API pública (el AST de clang o el
JSON de rustdoc), genera una capa con interfaz C, la compila y deja el
módulo en `~/.cforge/interop` (o `$CFORGE_INTEROP`). Los objetos se usan
como valores opacos (`Clase_nuevo`, `Clase_metodo`, `Clase_liberar`); las
excepciones, los `Err` y los pánicos llegan como errores de C-Forge. Lo que
no se puede traducir (plantillas, genéricos, callbacks, mapas) se omite con
un comentario en el módulo. Límites actuales: structs de C por valor y
métodos de Java o C# que devuelven `double`. Todo está probado en el CI (`tests/herramientas`,
`tests/npm`, `tests/interop`).

## Ecosistema de bibliotecas

[`docs/BIBLIOTECAS.md`](docs/BIBLIOTECAS.md) define las 251 bibliotecas del
ecosistema con nombres propios de C-Forge: cuáles ya existen, cuáles se usan
hoy vía interoperabilidad y cuáles están por construir (una por PR, con
pruebas en el CI).

## Construir desde el código fuente

C-Forge se compila a sí mismo: la semilla `bootstrap/semilla/cforge-linux-x64`
(un `cforge` para Linux x64) compila las fuentes. Solo hace falta `make`:

```sh
git clone https://github.com/VemorisSoftware/C-Forge.git
cd C-Forge
make                 # la semilla compila ./cforge
./cforge --version
make release-check   # gate completo (Stage 2 = Stage 3, suite, stdlib, CLI)
```

Desde Linux se generan los binarios de todas las plataformas, idénticos byte
por byte a los compilados en cada sistema: `make windows-cruzado`,
`make macos-cruzado`, `make macos-arm64-cruzado`, `make linux-arm64-cruzado`.

---

## Plataformas verificadas en 5.0.0

| Plataforma | Build CI | Tests | Distribuible |
|-----------|----------|-------|-------------|
| macOS ARM64 (Apple Silicon) | ✅ | ✅ | `.tar.gz` |
| macOS x64 (Intel) | ✅ | ✅ | `.tar.gz` |
| Linux x64 | ✅ | ✅ | `.tar.gz`, `.deb` |
| Linux ARM64 | ✅ (qemu) | ✅ | `.tar.gz`, `.deb` |
| Windows x64 | ✅ | ✅ | `.zip` |
| iOS ARM64 (biblioteca `--lib`) | ✅ (simulador) | ✅ | vía `cforge build --lib` |

---

## Seguridad

Reporta vulnerabilidades siguiendo [`SECURITY.md`](SECURITY.md).

---

## Licencia

Consulta [`LICENSE`](LICENSE). Copyright © 2026 Vemoris Group.

El estado verificable de cada componente está en [`capabilities.json`](capabilities.json).
