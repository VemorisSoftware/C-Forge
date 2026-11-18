# Casillas globales del runtime

El runtime de C-Forge no usa libc ni variables globales de C: guarda su
estado en un bloque de 512 bytes (64 casillas de 8 bytes) que devuelve
`__globales()`. Se leen con `mem_global(i)` / `mem_fijar_global(i, v)` o,
en el código más bajo, con `__cargar64(__globales() + 8·i)`.

**Antes de usar una casilla nueva, búscala en esta tabla.** En 4.1 las
tablas de AES ocupaban la 25 (el cerrojo del asignador) y luego la 26 (la
caché de `argv` en Windows): una casilla repetida no da error, corrompe el
estado en silencio.

## Programas del lenguaje (todas las plataformas)

| Casilla | Byte | Dueño | Contenido |
|---|---|---|---|
| 0 | 0 | `mem.cfv` | cursor de la arena actual |
| 1 | 8 | `mem.cfv` | fin de la arena actual |
| 2–13 | 16–104 | `mem.cfv` | listas libres de las clases 0–11 (16 B … 32 KiB) |
| 14 | 112 | `mem.cfv` | bytes en uso |
| 15 | 120 | `biblioteca.cfv` | tablas de AES (S-box e inversa) |
| 16 | 128 | `biblioteca.cfv` | handle de libssl (TLS con OpenSSL) |
| 17 | 136 | `io.cfv` | `cforge repl`: estado para omitir la salida ya mostrada |
| 18 | 144 | `mem.cfv` | estado del recolector de basura (ver `gc_activar`) |
| 19 | 152 | — | **libre** |
| 20 | 160 | `dyn.cfv` | programa escrito en inglés (1) |
| 21 | 168 | `dyn.cfv` | pila de manejadores de `intentar` del hilo principal |
| 22 | 176 | `biblioteca.cfv` | estado del generador `aleatorio` (xorshift64*) |
| 23 | 184 | `biblioteca.cfv` | constantes K de SHA-256 |
| 24 | 192 | `biblioteca.cfv` | tablas de MD5 |
| 25 | 200 | `mem.cfv` | **cerrojo del asignador** (no tocar) |
| 26 | 208 | `sys_windows.cfv` | caché de `argv` (Windows) |
| 27 | 216 | `sys_windows.cfv` | casilla temporal de `sys_casilla` (Windows) |
| 28 | 224 | `sys_windows_ext.cfv` | Winsock iniciado (Windows) |
| 29–30 | 232–240 | — | 29 libre; 30 la marca el compilador (`compilar_archivo`) |
| 31 | 248 | `biblioteca.cfv` | caché de bibliotecas abiertas (`extern`) |
| 32 | 256 | `biblioteca.cfv` | servidores HTTP (`servidor_http_*`) |
| 33 | 264 | CLI | plataforma de destino (`--target`) |
| 34 | 272 | `dyn.cfv` | bases de las pilas de los hilos de `tarea()` |
| 35 | 280 | `dyn.cfv` | cerrojo de la lista de hilos |
| 36–41 | 288–328 | compilador | ver abajo |
| 40–57 | 320–456 | `--lib` | programas compilados como biblioteca: 40 cerrojo, 41 iniciado, 42–49 `x0`–`x7`, 50–57 `d0`–`d7` |
| 60–63 | 480–504 | `sys_macos.cfv`, `sys_linux*.cfv` | `argc`, `argv`, `envp` y la pila inicial |

## Proceso del compilador (`cforge`)

| Casilla | Contenido |
|---|---|
| 19 | `build --release`: eliminar el código que no se usa |
| 36 | tabla de paquetes (`cforge.toml`) |
| 37 | archivo de diagnósticos (`check --diagnosticos`): `rt_panico` escribe ahí |
| 38 | contenido alternativo del archivo (`check --contenido`, editor) |
| 39 | `mostrar` va a stderr (stdout es el protocolo del LSP) |
| 40 | modo biblioteca: 1 `.a`, 2 `.o` |
| 41 | texto de la cabecera C generada |

Las casillas 40–41 del compilador y las 40–57 de un programa `--lib` no
chocan: son procesos distintos.
