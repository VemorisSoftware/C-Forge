# Changelog — C-Forge

Sitio oficial: [c-forge.org](https://c-forge.org)

## Sin publicar (4.3)

- **WebAssembly (`cforge build --target wasm`):** nuevo backend
  `gen_wasm.cfv` sobre la misma capa `gen.cfv`. Genera `app.wasm`, el
  cargador `app.mjs` (navegador y Node.js) y `app.d.ts`. 28 de las 29 suites
  del lenguaje pasan en Node.js (la otra usa librerías C).
- **`extern "js"`** y llamadas de JavaScript a funciones de C-Forge
  (`cf.llamar("nombre", n)`).
- **`stdlib/navegador.cfv`:** DOM, eventos, animación, lienzo 2D y partículas
  WebGL2. Ejemplo: `ejemplos/web/particulas`.
- **c-forge.org:** la física de las partículas del sitio está escrita en
  C-Forge (`site/forja/forja.cfv`) y corre en WebAssembly.
- **`cociente(a, b)`** (división entera) y **`bits_y`, `bits_o`, `bits_xo`**,
  en línea entre enteros; `lista[i]` y `lista[i] = v` en línea.
- **`lista_direccion(l)`** para compartir los elementos de una lista sin
  copiarlos.

## 4.2.0 — 2026-11-18

- **`cforge repl`:** consola interactiva con estado (variables, funciones de
  varias líneas, `:programa`, `:limpiar`); una expresión suelta muestra su
  valor y los errores no cortan la sesión.
- **Interpolación estricta:** `{` interpola solo si la sigue una letra, `_` o
  `(` y cierra en la línea; JSON y GLSL ya no necesitan `\{`.
- **Notación científica:** `1e5`, `2.5e-3`, `6.02E+23`.
- **Recolector de basura:** marcado y barrido conservador sobre el asignador
  propio (raíces: globales, variables de nivel superior y pila del
  lenguaje), con bloques reciclados en cero y división de bloques libres.
  2 M iteraciones creando textos: de 1,7 GB a 9 MB de pico; un servidor HTTP
  con 10 000 solicitudes: de 231 MB a 8,6 MB. `memoria_estadisticas()`,
  `CFORGE_GC=0` (desactivar) y `CFORGE_GC_ESTRES=1` (pruebas). No recolecta
  mientras haya hilos de `tarea()` vivos.
- **Verificador de tipos estáticos:** `cforge check`, `build` y el LSP
  detectan antes de ejecutar los errores de tipo con anotaciones (`sea x:
  numero`, parámetros y retorno) e inferencia local (`sea n = 5`, si la
  variable no se vuelve a asignar): asignaciones, argumentos, valores de
  retorno, operadores (`texto - numero`, comparar lista con número),
  condiciones y `no` que no son booleanas. Lo que no se conoce sigue siendo
  dinámico (tipado gradual): ningún programa válido deja de compilar.
- **Velocidad:** `+ - * %` y comparaciones de enteros en línea (sin llamar
  al runtime), enteros probados por el verificador sin comprobar etiquetas y
  condiciones booleanas de una instrucción. Primos hasta 200 000 + fib(30):
  de 460 ms a 73 ms (Java 21: 67 ms, gcc -O2: 25 ms).
- **`cforge build --release`:** elimina las funciones que el programa no usa
  (dos pasadas). "hola": de 231 KB a 34 KB en Linux.
- **Punteros seguros:** `*T` nunca es nulo y `?T` / `?*T` se comprueba antes
  de usarse (`si (q) |nodo| { … }` o `si (q != nulo)`); los errores salen en
  `cforge check`, `build` y el LSP.
- **`comptime`:** `comptime(expr)` y `comptime { … }` se ejecutan al compilar
  y quedan como literales; genéricos `comptime T` verificados por llamada.
- **WebSocket real (RFC 6455)** en `stdlib/red.cfv`: cliente (`ws_conectar`,
  `ws_conectar_url`) y servidor (`ws_aceptar` sobre `servidor_http_*`),
  texto, binario, fragmentación, ping/pong y cierre con código. Reemplaza el
  atajo por UDP.
- **PostgreSQL nativo** (`stdlib/postgres.cfv`): protocolo v3 sin libpq,
  SCRAM-SHA-256 (con verificación de la firma del servidor), MD5, consultas
  con parámetros por el protocolo extendido y tipos convertidos.
- **MySQL / MariaDB nativo** (`stdlib/mysql.cfv`): protocolo 4.1,
  mysql_native_password y caching_sha2_password (autenticación rápida),
  parámetros `?` escapados. La autenticación completa de caching_sha2 sin TLS
  (RSA) no está soportada.
- **Runtime:** `cfv_sha1`, `sha1_bytes`, `sha256_bytes`, `hmac_sha256_bytes`,
  `pbkdf2_sha256`, `bytes_entero`, `bytes_leer_entero`, `bytes_xor`,
  `bytes_buscar`, `bytes_de_hex`, `hex_de_bytes`, `net_recibir_exacto`,
  `servidor_http_tomar_conexion`.
- **`docs/GLOBALES.md`:** mapa de las casillas globales del runtime. Corrige
  dos choques de 4.1: las tablas de AES usaban la caché de `argv` en Windows
  (ahora casilla 15) y el handle de libssl la casilla de `sys_casilla` (16).

## 4.1.0 — 2026-11-18

- **Biblioteca estándar completa en C-Forge:** los 35 módulos de `stdlib/`
  cargan con el compilador nativo; `stdlib/PENDIENTES` desaparece.
- **Red:** cliente HTTP/1.1 (`http_solicitud`, chunked, redirecciones,
  cabeceras en un mapa), TCP (`net_*`), UDP (`udp_*`) y DNS propio en Linux
  (`/etc/hosts` y consulta A por UDP); `getaddrinfo` en macOS y Windows.
- **HTTPS:** `stdlib/tls.cfv` con OpenSSL 3/1.1 (Linux, macOS con
  `openssl@3`) y Schannel (Windows), verificando certificados y nombre.
- **SQLite:** `stdlib/sqlite.cfv` y `db.cfv` sobre la biblioteca del sistema
  (`libsqlite3`, `/usr/lib/libsqlite3.dylib`, `winsqlite3.dll`).
- **OpenGL 3.3 core:** `runtime/gl3d.cfv` (shaders, VBO, uniformes,
  profundidad, `glReadPixels`) y `gl_ventana`; matrices con trigonometría real.
- **Cripto:** `hmac_sha256`, AES-256-CBC compatible con OpenSSL y
  `crypto_rand_bytes` con el generador del sistema.
- **Lenguaje y runtime:** `lista + lista`, `__ccall` con la ABI de Windows y
  hasta 8 argumentos, `c_llamar`, `c_f32`, `c_cadena`, `c_leer64`; nombres de
  3.x que faltaban (`subarray`, `separar`, `unir`, `texto_subcadena`, …).
- Correcciones en módulos que estaban rotos en 3.x: `redis` (respuestas con
  CRLF), `auth` (OAuth con `http_solicitud`), `db_actualizar`/`db_eliminar`
  devuelven filas afectadas, el ejemplo de `gl`.

## 4.0.0 — 2026-11-18

- **100 % C-Forge: se retiró el C++.** El intérprete `cforgev.cpp`
  (`cforge-clasico`), el Stage 0 en C++20, `include/` y la cadena de
  arranque antigua (compilador Core, backends `bootstrap/direct`) salen del
  repositorio. La semilla `bootstrap/semilla/cforge-linux-x64` compila
  `cforge` (Stage 2 = Stage 3); Makefile, CI, release, Docker, `.deb`,
  Homebrew e instaladores usan solo C-Forge. Releases nuevas: Linux ARM64
  (`.tar.gz` y `.deb`) y macOS Intel.
- `cforge test`, `cforge new` (alias de `init`), `cforge doctor`,
  `paralelo(f, lista)`, `tiempo_actual()` y los
  alias `file_write` / `file_read`.
- **Pendiente para 4.1:** 14 módulos de la stdlib que usaban funciones del
  intérprete C++ (`stdlib/PENDIENTES`: cripto, bases de datos, cliente
  HTTP/TLS, WebSocket, UDP, OpenGL, audio…), un recolector de basura para
  cadenas temporales y `cforge repl`.

- **Backend nativo ELF sin libc** (`bootstrap/nativo/`): código máquina x86-64
  directo con marcos de pila y recursión; ejecutables estáticos de pocos KB.
- **Runtime 100 % C-Forge** (`runtime/`): syscalls de Linux aisladas en
  `sys_linux.cfv`, asignador propio sobre `mmap` con listas libres, textos y
  listas dinámicas, archivos y formato de decimales.
- **Primer hito de autoalojamiento**: el lexer de C-Forge escrito en el
  dialecto nativo produce los mismos tokens que el lexer Core.
- `make nativo-check` y job de CI "Backend nativo (Linux, sin libc)".
- **Compilador autoalojado** (`bootstrap/nativo/cforge_self.cfv`): compilador
  de una pasada escrito en el dialecto nativo que se compila a sí mismo.
  Stage 2 = Stage 3 byte por byte, sin libc ni C++ (`make autoalojado-check`).
- **Listas y mapas nativos** en el compilador autoalojado: valores dinámicos
  etiquetados, `runtime/map.cfv` (tabla hash) y `runtime/dyn.cfv`. Las pruebas
  de colecciones de la suite pasan compiladas a ELF sin libc.
- **Clases nativas** en el compilador autoalojado: clases, estructuras,
  herencia, `super`, interfaces, despacho dinámico de métodos, palabras clave
  en inglés y errores con `archivo.cfv:línea`.
- **Funciones anónimas y errores nativos**: cierres con captura por
  referencia, globales, `intentar`/`capturar`/`finalmente`/`lanzar`, `??`.
  15 de 25 pruebas de la suite compiladas a ELF sin libc.
- **Biblioteca estándar nativa** (`runtime/biblioteca.cfv`, JSON y regex en
  `runtime/lenguaje.cfv`), interpolación de textos y `si(c, a, b)`:
  24 de 25 pruebas de la suite compiladas a ELF sin libc.
- **`extern` nativo**: `cforge_self` genera ELF dinámicos por sí mismo
  (PT_INTERP, PT_DYNAMIC, GOT, ABI System V). **25 de 25 pruebas de la suite
  compiladas por el compilador autoalojado.**
- **`cforge` 100 % C-Forge en Linux**: CLI nativo (`run`, `build`, `check`)
  con runtime incrustado, semilla de arranque sin C++ verificada en CI, y
  releases/instalador que distribuyen el compilador nativo como `cforge`
  (con `cforge-clasico` para lo que aún no es nativo).
- **22/22 `ejemplos/` con el compilador nativo**: `extern` genérico con
  `dlopen` (SDL2, sqlite3, cualquier `.so`), hilos reales con `clone` y
  `futex`, canales y mutex, servidor HTTP con sockets, SDL2 en C-Forge,
  `?.`, ternario, `expr?`, genéricos, valores por defecto, variádicos,
  `inseguro` con punteros verificados y atributos `#[...]`.
- **Windows x86-64 100 % C-Forge**: backend PE64 con IAT, ABI x64 de
  Windows, `runtime/sys_windows*.cfv`, hilos con `CreateThread`, Winsock y
  `extern` con `LoadLibrary`. En Windows real: Stage 2 = Stage 3 = compilación
  cruzada desde Linux; 25/25, 32/32 y 22/22.

## 3.7.3 — extern C + idioma del programa

- **FFI con C**: `extern "libreria" funcion nombre(p: tipo): tipo` carga la
  librería (dlopen / LoadLibrary) y llama con la ABI de C de la plataforma.
  Tipos: entero, largo, numero, texto, puntero, booleano, vacio (y sus nombres
  en inglés). `"libc"` y `"libm"` se resuelven solos. Hasta 8 parámetros, sin
  variádicas. Prueba `24_extern_c.cfv`.
- **Idioma del programa**: si predominan las palabras clave en inglés, los
  booleanos/nulo se muestran como true/false/null y los errores comunes en
  inglés. Prueba `25_idioma_ingles.cfv`.
- **docs/SPEC.md**: especificación oficial con estado real de cada pieza.
- Ejemplos de `extern` en c-forge.org (Aprende / Learn).

## 3.7.2 — sintaxis bilingüe + nuevo c-forge.org

- **Sintaxis bilingüe**: las palabras clave en inglés (`let`, `function`,
  `return`, `if`, `else`, `while`, `for`, `in`, `try`, `catch`, `throw`,
  `class`, `this`, `import`, `break`, `continue`, `and`, `or`, `not`, `true`,
  `false`, `null`, `print`, `assert`) son alias exactos del español y se pueden
  mezclar en un mismo archivo. Tras un `.` no se traducen.
- **Funciones integradas en inglés**: `length`, `append`, `sort`, `upper`,
  `lower`, `replace`, `to_text`, `to_number`, `json_parse`, `json_stringify`,
  `json_pretty`, `json_valid`. Si el programa define una función o variable con
  ese nombre, se usa la suya.
- **c-forge.org rehecho**: sin inicio de sesión ni panel; páginas Inicio y
  Aprende generadas desde el repo. Ejemplos, versión, estado y novedades salen
  de fuentes verificables y `site/verificar.sh` los comprueba en CI.
- **Corrección**: una función definida por el programa ya no queda tapada por
  una integrada con el mismo nombre (p. ej. `dividir`, `contiene`).
- `capabilities.json`: multiplataforma pasa a estable (CI verde en Linux,
  macOS y Windows).

## 3.7.1 — instalación en un comando + Windows estable

- **install.sh único** (repo y c-forge.org): descarga el binario de GitHub
  Releases, verifica SHA-256 y compila desde fuente si no hay binario para la
  plataforma. Instala en `~/.local` si no hay `sudo`.
- **install.ps1** nuevo para Windows: `irm https://c-forge.org/install.ps1 | iex`.
- **Stdlib automática**: `cforge` busca la stdlib junto al ejecutable; ya no se
  necesita `CFORGE_STDLIB`.
- **Windows**: el fallo de la suite con MSVC era la pila de 1 MB; se enlaza con
  64 MB y la suite completa vuelve a ser obligatoria en CI y release.
- **macOS x86-64 nativo (Mach-O)**: `--target macos`, escritor Mach-O propio
  enlazado a `libSystem.B.dylib`, `runtime/sys_macos*.cfv` y CI en macOS real
  (Stage 2 = Stage 3 = compilación cruzada; 25/25, 32/32, 22/22).
- **Capa intermedia del generador** (`gen.cfv`, `gen_x64.cfv`, `gen_a64.cfv`)
  y **backend AArch64**: `--target macos-arm64` (Mach-O PIE con firma ad-hoc
  SHA-256 propia) y `--target linux-arm64`. Apple Silicon: Stage 2 = Stage 3
  = compilación cruzada desde Linux y Windows; 25/25, 32/32, 22/22.
- **Gestor de paquetes**: `cforge init`, `cforge add usuario/repo[@ref]`,
  `cforge remove`, `cforge install`, `cforge.toml` y `cforge.lock`; caché
  global de descargas de GitHub e `importar "alias"` / `"alias/modulo"`.
- **`cforge fmt`** (formateador idempotente que conserva los tokens) y
  **`cforge lsp`** (diagnósticos, autocompletado, definición, información y
  formateo), con la extensión de VS Code como cliente del servidor (`.vsix`).
- **Apple**: `cforge build --lib` (`.a` + `.h` de las funciones `#[Exportar]`),
  `--target ios-arm64` / `ios-sim-arm64`, `cforge xcode-init` (regla de
  Xcode, cabecera puente para Swift, `CForge.xclangspec`) y `stdlib/apple.cfv`
  (puente con Objective-C).
- **CI**: smoke test con rutas absolutas; se elimina `build-native.yml`
  (duplicado).
- **Web**: c-forge.org vive en `site/` y se despliega en Cloudflare Pages; se
  quitan comandos de brew/winget/scoop que no existían.
- Repositorio oficial: `VemorisSoftware/C-Forge`.

## 3.7.0 — CLI completo + versión centralizada + SDL2 estable + release automatizado

- **Versión centralizada**: Makefile es la única fuente de verdad para VERSION.
  `cfv_version()` lee la constante compilada; `--version` y el REPL son siempre
  coherentes. Procedimiento de bump documentado en Makefile.
- **CLI completo**: añadidos `cforge new <nombre>`, `cforge init` y `cforge doctor`.
  - `new` crea directorio, `main.cfv` y `cforge.json` en un solo paso.
  - `init` genera `cforge.json` en el directorio actual sin sobrescribir archivos.
  - `doctor` diagnostica versión, CFORGE_STDLIB, compilador C++ disponible,
    OpenSSL y SQLite.
- **SDL2 estable**: corregido "índice de lista inválido" en `sdl_eventos()` causado
  por el despacho del API antiguo que intentaba leer argumentos vacíos.
  Todos los eventos pasan ahora por el despacho dlopen unificado.
  `sdl_quiere_salir` y el bucle de evento de trafico_visual.cfv usan try/catch
  para claves ausentes en eventos de teclado.
- **release.yml**: artefactos versionados (`cforge-3.7.0-linux-x64.tar.gz`, etc.),
  validación de que el tag coincide con Makefile VERSION, generación de
  `release-manifest.json` para c-forge.org.
- **install.sh**: auto-detecta la versión más reciente desde la GitHub Releases API;
  fallback a 3.7.0 si la red no está disponible. Añadidos `new`, `init` y `doctor`
  al texto de ayuda post-instalación.
- **capabilities.json**: actualizado a 3.7.0; scope de `native-cli` refleja los
  comandos reales implementados.
- **Extensión VS Code 3.7.0**: CHANGELOG reescrito con información real; eliminadas
  referencias a puentes Java/Python/JS que no existen en esta versión.
- Herramientas de tipo y compilación escritas en C-Forge (`cftype.cfv`, `cfpkg.cfv`);
  los archivos Python anteriores (`cftype.py`, `cf2c.py`) no forman parte del
  repositorio — toda la toolchain es autónoma.

## 3.2.0 — dominio oficial + concurrencia real + compilación nativa

- Dominio oficial adquirido: **c-forge.org**
- Concurrencia real con `std::thread`: `hilo_crear`, `hilo_esperar`, `hilo_id`, `hilo_activo`.
- Mutex reales: `mutex_crear`, `mutex_bloquear`, `mutex_desbloquear`, `mutex_intentar`.
- Canales thread-safe integrados con el sistema de hilos.
- Soporte Unicode avanzado: bytes ≥ 0x80 aceptados en identificadores.
- Herramientas de tipo e introspección implementadas en `.cfv`.
- LSP básico funcional en la extensión VS Code.
- BDD testing stdlib (`describir/cuando/entonces`).
- Backends directos (Mach-O ARM64, ELF x64, PE x64) en estado parcial.

## 2.6.0 — primer núcleo estable

- Eliminados de las dos fuentes C++ los puentes heredados de Python, Java/JNI y
  JavaScript.
- Motor y CLI unificados bajo el ejecutable `cforge`.
- Biblioteca activa reducida a 31 módulos `.cfv` que pasan sintaxis y carga.
- Suite nativa ampliada a 15 archivos `.cfv`.
- Parser JSON endurecido frente a entradas truncadas, tokens inválidos y datos
  sobrantes.
- Construcción oficial reducida de 292 avisos a cero en el entorno local.
- Gate reproducible para build, sintaxis, carga real de 31 módulos, pruebas,
  CLI, entradas dañadas, ASan/UBSan, emisores directos e instalación aislada.
- Empaquetado Homebrew y Debian migrado al motor nativo, sin Python.
- Flujos de CI y release renovados para compilar el motor nativo en macOS,
  Linux y Windows.
- Backends directos reclasificados correctamente como prototipos limitados a
  `mostrar("texto")`.
- Artefactos históricos, caches y módulos incompletos retirados del árbol
  activo de forma recuperable.
- Runtime, CLI, JSON y núcleo de biblioteca declarados estables; red, bases de
  datos, criptografía, gráficos, backends completos y autoalojamiento conservan
  explícitamente sus estados experimental, parcial o planeado.

Las versiones anteriores mezclaban prototipos y afirmaciones no respaldadas.
Su historial permanece disponible en Git, pero no define las capacidades del
producto actual. La fuente de verdad es `capabilities.json`.
