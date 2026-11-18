# C-Forge para VS Code

Soporte oficial del lenguaje **C-Forge** (`.cfv`) — [c-forge.org](https://c-forge.org)

## Funciones

- **Servidor de lenguaje** (`cforge lsp`, escrito en C-Forge):
  - diagnósticos mientras escribes, en la línea exacta del error;
  - autocompletado de tus funciones, clases y variables, de lo que importas
    (archivos, paquetes de `cforge.toml` y biblioteca estándar), de la
    biblioteca del lenguaje y de las palabras clave;
  - ir a la definición (F12) e información al pasar el cursor;
  - formateo del documento (`cforge fmt`, Shift+Alt+F).
- Resaltado de sintaxis, fragmentos y cierre automático de llaves y comillas.
- Comandos: *C-Forge: Ejecutar archivo*, *Comprobar archivo*, *Formatear
  archivo* y *Reiniciar el servidor de lenguaje*.

## Requisitos

Instala C-Forge (`cforge --version`) desde [c-forge.org](https://c-forge.org).
Si `cforge` no está en el `PATH`, indica su ruta en el ajuste `cforge.ruta`.

## Ajustes

| Ajuste | Por defecto | Descripción |
|---|---|---|
| `cforge.ruta` | `cforge` | Ejecutable de C-Forge |
| `cforge.lsp.habilitado` | `true` | Iniciar el servidor de lenguaje |

Copyright © 2026 Vemoris Group. Todos los derechos reservados.
