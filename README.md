# C-Forge

![C-Forge](assets/cforgev-logo.svg)

**[c-forge.org](https://c-forge.org)** · [GitHub](https://github.com/VemorisSoftware/C-Forge) · [Releases](https://github.com/VemorisSoftware/C-Forge/releases)

C-Forge es un lenguaje de programación creado por Vemoris Group. Su objetivo es ofrecer una sintaxis clara, ejecución nativa y una biblioteca estándar escrita en el propio lenguaje.

> **C-Forge 4.2.0** — El núcleo, CLI y biblioteca estándar superan el gate reproducible `make release-check` en macOS ARM64, Linux x64 y Windows x64. Las capacidades marcadas como experimentales no forman parte del contrato estable.

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
curl -fsSL https://c-forge.org/install.sh | CFORGE_VERSION=4.2.0 sh   # versión fija
curl -fsSL https://c-forge.org/install.sh | CFORGE_PREFIX=$HOME/.local sh   # sin sudo
```

> **macOS:** el binario no está firmado con Apple Developer ID; el instalador
> quita la marca de cuarentena para que Gatekeeper no lo bloquee.

### Linux x64 (.deb)

```sh
wget https://github.com/VemorisSoftware/C-Forge/releases/download/v4.2.0/cforge_4.2.0_amd64.deb
sudo dpkg -i cforge_4.2.0_amd64.deb
```

### Windows x64

1. Descarga `cforge-4.2.0-windows-x64.zip` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/latest).
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
# → C-Forge 4.2.0

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

1. Descarga `c-forge-4.2.0.vsix` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/tag/v4.2.0).
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

## Plataformas verificadas en 4.2.0

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
