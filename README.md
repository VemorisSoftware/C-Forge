# C-Forge

![C-Forge](assets/cforgev-logo.svg)

**[c-forge.org](https://c-forge.org)** · [GitHub](https://github.com/VemorisSoftware/C-Forge) · [Releases](https://github.com/VemorisSoftware/C-Forge/releases)

C-Forge es un lenguaje de programación creado por Vemoris Group. Su objetivo es ofrecer una sintaxis clara, ejecución nativa y una biblioteca estándar escrita en el propio lenguaje.

> **C-Forge 3.7.3** — El núcleo, CLI y biblioteca estándar superan el gate reproducible `make release-check` en macOS ARM64, Linux x64 y Windows x64. Las capacidades marcadas como experimentales no forman parte del contrato estable.

---

## Instalación rápida

### macOS (Apple Silicon) y Linux x64

```sh
curl -fsSL https://c-forge.org/install.sh | sh
```

El instalador descarga el binario oficial desde GitHub Releases, verifica su
SHA-256 e instala `cforge` en `/usr/local/bin` (o en `~/.local/bin` si no hay
`sudo`). La biblioteca estándar queda en `<prefijo>/lib/cforge/stdlib` y
`cforge` la encuentra solo: **no hace falta configurar `CFORGE_STDLIB`**.

En otras arquitecturas (Mac Intel, Linux ARM) el mismo comando compila desde
el código fuente; necesitas `make` y un compilador C++20
(`xcode-select --install` o `sudo apt install g++ make`).

Opciones:

```sh
curl -fsSL https://c-forge.org/install.sh | CFORGE_VERSION=3.7.3 sh   # versión fija
curl -fsSL https://c-forge.org/install.sh | CFORGE_PREFIX=$HOME/.local sh   # sin sudo
```

> **macOS:** el binario no está firmado con Apple Developer ID; el instalador
> quita la marca de cuarentena para que Gatekeeper no lo bloquee.

### Linux x64 (.deb)

```sh
wget https://github.com/VemorisSoftware/C-Forge/releases/download/v3.7.3/cforge_3.7.3_amd64.deb
sudo dpkg -i cforge_3.7.3_amd64.deb
```

### Windows x64

1. Descarga `cforge-3.7.3-windows-x64.zip` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/latest).
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
# → C-Forge 3.7.3

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

1. Descarga `c-forge-3.7.3.vsix` desde [Releases](https://github.com/VemorisSoftware/C-Forge/releases/tag/v3.7.3).
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

Módulos estables: `matematica`, `lista`, `mapa`, `colecciones`, `algoritmos`, `texto`, `json`, `errores`, `io`, `fecha`, `numero`, `base64`, `regex`, `concurrencia`, `aleatorio`, `sdl`.

Módulos experimentales (presentes, sin garantías de producción): `web`, `db`, `crypto`, `gl`, `red`, `redis`, `audio`, `auth`.

---

## Construir desde el código fuente

Requiere un compilador C++20 (g++ ≥ 12 o clang++ ≥ 14):

```sh
git clone https://github.com/VemorisSoftware/C-Forge.git
cd C-Forge
make build
./cforge --version
make release-check   # gate completo
```

---

## Plataformas verificadas en 3.7.3

| Plataforma | Build CI | Tests | Distribuible |
|-----------|----------|-------|-------------|
| macOS ARM64 (Apple Silicon) | ✅ | ✅ | `.tar.gz` |
| Linux x64 | ✅ | ✅ | `.tar.gz`, `.deb` |
| Windows x64 | ✅ | ✅ | `.zip` |

---

## Seguridad

Reporta vulnerabilidades siguiendo [`SECURITY.md`](SECURITY.md).

---

## Licencia

Consulta [`LICENSE`](LICENSE). Copyright © 2026 Vemoris Group.

El estado verificable de cada componente está en [`capabilities.json`](capabilities.json).
