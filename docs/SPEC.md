# C-Forge — Especificación del lenguaje

Versión del documento: 4.1.0 · Extensión de archivos: **`.cfv`** · CLI: **`cforge`**

Este documento fija la sintaxis oficial de C-Forge y el estado real de cada
pieza. Cada sección lleva una etiqueta:

| Etiqueta | Significado |
|---|---|
| **✅ Disponible** | Funciona en la versión publicada y tiene pruebas en `tests/cfv/`. |
| **🧪 Experimental** | Funciona, pero su API puede cambiar. |
| **🛠️ En desarrollo** | Existe en el núcleo nativo (`bootstrap/`) o en una rama, todavía no en `cforge`. |
| **📐 Diseño** | Sintaxis decidida; falta implementarla. Puede ajustarse antes de publicarse. |

Nada marcado como 📐 debe aparecer en c-forge.org como si ya existiera.

---

## 1. Principios

1. **Un solo binario, cero runtimes externos.** `cforge` ejecuta, prueba,
   formatea y compila. Sin VM, sin intérprete aparte, sin gestor externo.
2. **Bilingüe.** Toda palabra clave existe en español e inglés y se pueden
   mezclar. Los valores y errores siguen el idioma mayoritario del programa.
3. **Seguridad por defecto, control cuando se pide.** Memoria determinista sin
   recolector de basura; lo inseguro se marca explícitamente.
4. **Lo mejor de cuatro lenguajes:**
   - de **C**: código nativo y acceso directo a librerías C;
   - de **C++**: abstracciones de costo cero y destrucción determinista (RAII);
   - de **C#**: sintaxis limpia, `async`/`await`, errores ergonómicos;
   - de **Java**: tipado estático, portabilidad y biblioteca estándar completa.

---

## 2. Léxico ✅

- Archivos UTF-8 con extensión `.cfv`.
- Comentarios de línea: `// ...`
- Textos entre comillas dobles. `{expresión}` interpola cuando la llave va
  seguida de una letra, `_` o `(` y se cierra en la misma línea
  (`"Hola {nombre}"`, `"{(a + b)}"`); cualquier otra llave es literal, así
  JSON (`"{\"a\": 1}"`) y GLSL (`"main() {"`) no necesitan escapes. `\{` y
  `\}` siguen siendo llaves literales. Escapes: `\n`, `\t`, `\"`, `\\`.
- Números decimales (`42`, `3.14`) y con exponente (`1e5`, `2.5e-3`, `6.02E+23`).

### Palabras clave (español ⇄ inglés) ✅

| Español | Inglés |
|---|---|
| `sea` | `let` |
| `funcion` · `retornar` | `function` · `return` |
| `si` · `sino` | `if` · `else` |
| `mientras` · `para` … `en` | `while` · `for` … `in` |
| `romper` · `continuar` | `break` · `continue` |
| `intentar` · `capturar` · `lanzar` | `try` · `catch` · `throw` |
| `clase` · `esto` | `class` · `this` |
| `importar` | `import` |
| `y` · `o` · `no` | `and` · `or` · `not` |
| `verdadero` · `falso` · `nulo` | `true` · `false` · `null` |
| `mostrar` · `afirmar` | `print` · `assert` |
| `extern` | `extern` |

Tras un `.` las palabras no se traducen (`objeto.in` es un campo llamado `in`).

---

## 3. Valores y tipos

### 3.1 Tipos dinámicos actuales ✅

`numero`, `texto`, `booleano`, `lista`, `mapa`, `nulo`, funciones y objetos de
clase.

### 3.1b Verificación de tipos antes de ejecutar ✅ (4.2)

Las anotaciones se comprueban al compilar (`cforge check`, `build`, `run` y
el LSP), con inferencia local para `sea n = 5` cuando la variable no se
vuelve a asignar. Es tipado gradual: lo que no se conoce (resultado de una
llamada sin anotación, un índice, un campo) sigue siendo dinámico.

```cfv
funcion area(ancho: numero, alto: numero): numero { retornar ancho * alto }
area("dos", 3)        // error de tipos: el argumento 1 de area espera numero y recibe texto
sea n = 5
si (n) { … }          // error de tipos: la condición espera booleano y recibe entero
```

Se comprueban: asignaciones y `sea` anotados, argumentos y valores de
retorno anotados, `+ - * / %` y comparaciones entre tipos incompatibles, y
condiciones o `no` que no son booleanas. `nulo` es compatible con cualquier
tipo y `entero` con `numero`. Tipos: `entero`, `numero`, `texto`,
`booleano`, `lista` (o `T[]`), `mapa`, `nulo`, `funcion` (también en inglés).

### 3.2 Tipos estáticos 📐

```cfv
sea edad: i32 = 30
sea precio: f64 = 9.99
sea nombre: texto = "Ana"
sea puntos: lista<i32> = [1, 2, 3]
sea mapa: mapa<texto, i32> = {"a": 1}
```

Tipos numéricos de tamaño fijo: `i8 i16 i32 i64 u8 u16 u32 u64 f32 f64`, más
`isize`/`usize`. El verificador de tipos rechaza el programa antes de
ejecutarlo; no hay conversiones implícitas con pérdida.

### 3.3 Opcionales y punteros seguros 📐

```cfv
sea p: *Nodo = nuevo Nodo(1)     // nunca nulo
sea q: ?*Nodo = nulo             // puede ser nulo
si (q) |nodo| { mostrar(nodo.valor) }   // desempaque seguro
```

`*T` no puede ser nulo. `?T` obliga a comprobar antes de usar. La aritmética de
punteros solo existe dentro de `inseguro { ... }`.

### 3.4 Resultado y operador `?` 📐

```cfv
funcion leer_config(ruta: texto): Resultado<Config, Error> {
    sea texto = leer_archivo(ruta)?      // si falla, retorna el error
    retornar Ok(parsear(texto)?)
}
```

`Resultado<T, E>` es un valor normal: no hay desenrollado de pila ni costo
oculto. `intentar` / `capturar` sigue disponible para errores lanzados con
`lanzar`.

---

## 4. Control de flujo ✅

```cfv
si (n < 0) { mostrar("negativo") } sino { mostrar("no negativo") }

mientras (i < 10) { i = i + 1 }

para fruta en ["manzana", "pera"] { mostrar(fruta) }

intentar { lanzar "fallo" } capturar (e) { mostrar(e) }
```

---

## 5. Funciones ✅

```cfv
funcion factorial(n) {
    si (n <= 1) { retornar 1 }
    retornar n * factorial(n - 1)
}

funcion crear_sumador(base) {
    retornar funcion(valor) { retornar base + valor }   // closure
}
```

Las funciones del programa tienen prioridad sobre las integradas con el mismo
nombre.

---

## 6. Clases ✅ y RAII

### 6.1 Clases ✅

```cfv
clase Cuenta {
    sea saldo = 0
    funcion constructor(inicial) { esto.saldo = inicial }
    funcion depositar(monto) { esto.saldo = esto.saldo + monto }
}
```

### 6.2 Destrucción determinista (RAII) 🛠️

Implementada en el núcleo nativo (`bootstrap/core_object_lowering.cfv`,
verificada por `make backend-core-check`); falta llevarla a `cforge`.

```cfv
clase Archivo {
    campo descriptor: i32

    metodo crear(ruta: texto) {
        este.descriptor = abrir(ruta)
    }

    metodo destruir() {          // se llama sola al salir del bloque
        cerrar(este.descriptor)
    }
}

funcion procesar() {
    sea log = Archivo("app.log")
    escribir(log, "inicio")
}   // ← aquí se ejecuta log.destruir(), en orden inverso de creación
```

Reglas (ya verificadas en el núcleo nativo):
- `destruir` corre en orden LIFO al salir de cada ámbito, también antes de
  `retornar` y `lanzar`.
- `mover(x)` transfiere la propiedad; usar `x` después es un error de
  compilación.
- `prestar(x)` / `prestar_mut(x)` crean préstamos; no se puede mover ni
  modificar un valor mientras está prestado.

---

## 7. Módulos ✅

```cfv
// geometria.cfv
funcion area_circulo(r) { retornar 3.14159 * r * r }

// main.cfv
importar "geometria"          // busca geometria.cfv junto al archivo
importar "json"               // o en la biblioteca estándar
mostrar(area_circulo(2))
```

Orden de búsqueda: carpeta del archivo, `./stdlib`, `./cforge_modules`, la
stdlib junto al ejecutable, `~/.cforge/stdlib` y `CFORGE_STDLIB`. Cada módulo
se carga una sola vez.

📐 Próximo paso: espacios de nombres (`importar "json" como js` →
`js.parsear(...)`) y paquetes con `cforge.json`.

---

## 8. Interoperabilidad con C ✅

```cfv
extern "libc"    funcion strlen(s: texto): largo
extern "libm"    funcion pow(base: numero, exp: numero): numero
extern "sqlite3" funcion sqlite3_libversion(): texto

mostrar(strlen("C-Forge"))          // 7
mostrar(pow(2, 10))                 // 1024
mostrar(sqlite3_libversion())       // 3.45.1
```

| Tipo C-Forge | Tipo C |
|---|---|
| `entero` / `int` | `int` |
| `largo` / `long` | `int64_t` |
| `numero` / `number` | `double` |
| `texto` / `string` | `const char*` (entrada) · `char*` copiado (salida) |
| `puntero` / `pointer` | `void*` |
| `booleano` / `bool` | `int` (0 / 1) |
| `vacio` / `void` | `void` |

- Usa la ABI de C de cada plataforma: System V AMD64 (Linux, macOS Intel),
  AAPCS64 (macOS Apple Silicon) y Microsoft x64 (Windows).
- `"libc"` y `"libm"` se resuelven solos; para otras librerías, nombre corto o
  ruta.
- Límites actuales: hasta 8 parámetros; sin funciones variádicas (`printf`);
  sin estructuras por valor.

📐 Siguiente: `importar c "sqlite3.h"` lee la cabecera y declara las funciones
automáticamente; estructuras C por valor y callbacks.

📐 Puentes con JVM (JNI) y .NET (hosting API): fuera del núcleo, como paquetes
opcionales. El núcleo nunca depende de ellos (`docs/CORE-DIRECTION.md`).

---

## 9. Concurrencia

### 9.1 Tareas ✅ 🧪

```cfv
sea t = tarea(funcion() { retornar 20 + 22 })
mostrar(esperar(t))          // 42
```

### 9.2 `async` / `await` 📐

```cfv
asincrona funcion descargar(url: texto): texto {
    sea r = esperar http.obtener(url)
    retornar r.cuerpo
}
```

En inglés: `async function` y `await`. Se compila a una máquina de estados sin
hilos ocultos.

---

## 10. Ejecución en tiempo de compilación (`comptime`) 📐

```cfv
funcion tabla_cuadrados(n: usize): [n]u32 {
    sea t: [n]u32
    para i en 0..n { t[i] = i * i }
    retornar t
}

constante CUADRADOS = comptime tabla_cuadrados(256)   // calculado al compilar

funcion Pila(comptime T: tipo): tipo {                  // genéricos = funciones
    retornar estructura { datos: lista<T>, tope: usize }
}
```

Cualquier función sin efectos externos puede ejecutarse al compilar. Los
genéricos son funciones que reciben y devuelven tipos.

---

## 11. Biblioteca estándar

| Módulo | Estado |
|---|---|
| `lista`, `mapa`, `colecciones`, `algoritmos`, `texto`, `matematica`, `numero`, `json`, `fecha`, `regex`, `base64`, `io`, `errores`, `aleatorio` | ✅ |
| `red`, `web`, `db`, `crypto`, `auth`, `redis` | 🧪 |
| `sdl`, `gl`, `juego`, `fisica2d`, `fisica3d`, `audio` | 🧪 |

📐 Con `extern`, `db` pasará a usar SQLite directamente y `crypto` una
implementación auditada, en vez de envoltorios propios.

---

## 12. Herramientas

| Comando | Estado |
|---|---|
| `cforge archivo.cfv`, `run`, `repl`, `check`, `test`, `fmt`, `new`, `init`, `doctor` | ✅ |
| `cforge build archivo.cfv -o app` (requiere hoy gcc o clang) | ✅ |
| `cforge build` con compilador 100 % C-Forge | ✅ |
| `cforge add usuario/repo`, `cforge.toml` y `cforge.lock` | ✅ |
| LSP completo (diagnósticos, autocompletado, ir a definición) | ✅ |

---

## 13. Camino al compilador 100 % C-Forge

✅ **Cumplido.** `cforge` es un compilador escrito en C-Forge que emite código
máquina directo (x86-64 y AArch64) y se compila a sí mismo. El intérprete en
C++ (`cforgev.cpp`) y el Stage 0 en C++ se retiraron del repositorio: la
semilla `bootstrap/semilla/cforge-linux-x64` es el punto de partida (ver
`docs/BOOTSTRAP.md`), como Go se compila con Go.

Estado del núcleo nativo (`bootstrap/`):

- ✅ Frontend escrito en `.cfv` que se compila a sí mismo (Stage 2 = Stage 3).
- ✅ Backends directos ELF x64, Mach-O ARM64 y PE x64 para el subconjunto Core:
  variables, aritmética, condiciones, ciclos, funciones, listas y textos de
  tamaño conocido, objetos, métodos, interfaces, módulos, excepciones,
  ownership y RAII.

Lo que falta en los backends directos para compilar el propio compilador:

1. **Valores dinámicos en tiempo de ejecución:** listas y textos que crecen
   (`agregar`, concatenación en ciclos) y mapas con claves no conocidas al
   compilar.
2. **Montículo (heap) propio:** asignador sobre `mmap` / `VirtualAlloc`, sin
   libc.
3. **Llamadas a funciones con recursión profunda** y objetos que viven más allá
   del ámbito que los creó.
4. **Entrada/salida por llamadas al sistema:** leer y escribir archivos y
   argumentos del programa.
5. **Formato de números decimales** (`a_texto(3.5)`).
6. **Despacho de métodos por nombre** y `cualquiera` en tiempo de ejecución.

### Avance: backend nativo con runtime propio (Linux x86-64) ✅

`bootstrap/nativo/x64_nativo.cfv` es un backend nuevo, escrito en C-Forge, que
genera ELF estáticos **sin libc, sin enlazador y sin ensamblador**. A diferencia
de los backends Core anteriores, tiene marcos de pila por función (recursión
real) y un runtime escrito en C-Forge sobre intrínsecos mínimos:

| Archivo | Contenido |
|---|---|
| `runtime/sys_linux.cfv` | Única capa que conoce el sistema: `read`, `write`, `open`, `close`, `mmap`, `munmap`, `exit`, argumentos. Portar = escribir `sys_macos.cfv` / `sys_windows.cfv`. |
| `runtime/mem.cfv` | Asignador propio: arenas de 64 MiB con `mmap` + listas libres por clase (16 B – 32 KiB); bloques grandes con `mmap`/`munmap` directo. |
| `runtime/str.cfv` | Textos que crecen, concatenación, rebanado, comparación, enteros → texto. |
| `runtime/vec.cfv` | Listas dinámicas con verificación de límites. |
| `runtime/io.cfv` | `mostrar`, lectura y escritura de archivos, argumentos. |
| `runtime/f64.cfv` | Decimales → texto. |

Intrínsecos del dialecto nativo: `__syscall`, `__cargar64`, `__cargar8`,
`__guardar64`, `__guardar8`, `__y_bits`, `__o_bits`, `__xo_bits`,
`__desplazar_izq`, `__desplazar_der`, `__globales`, `__argc`, `__argv`,
`__f64_desde_entero`, `__f64_a_entero`, `__f64_suma`, `__f64_resta`,
`__f64_mul`, `__f64_div`, `__f64_menor`.

Primer hito de autoalojamiento: `tests/nativo/05_lexer.cfv` es el lexer de
C-Forge compilado por este backend; produce exactamente los mismos tokens que
el lexer Core sobre las fuentes del compilador (`make nativo-check`, en CI).

### Hito: compilador autoalojado (Linux x86-64) ✅

`bootstrap/nativo/cforge_self.cfv` es un compilador de una sola pasada escrito
en el dialecto nativo: el parser de descenso recursivo emite código x86-64
mientras lee los tokens, sin árbol de sintaxis, y empaqueta el ELF.

`make autoalojado-check` (en CI):

1. `x64_nativo` construye **Stage 1** a partir de `runtime/*.cfv`,
   `lexer.cfv` y `cforge_self.cfv`.
2. Stage 1 se compila a sí mismo → **Stage 2**, con entorno vacío.
3. Stage 2 se compila a sí mismo → **Stage 3**.
4. Stage 2 y Stage 3 son idénticos byte por byte (≈48 KB, estáticos, sin
   libc). Stage 3 vuelve a compilar y pasar todas las pruebas nativas.

Desde Stage 1 en adelante no interviene C++, libc, enlazador ni ensamblador.
C++ queda solo en Stage 0, el paso de arranque.

### Bloque 1: listas y mapas en el compilador autoalojado ✅

`cforge_self` compila ahora el lenguaje dinámico (`--dinamico`) con valores
etiquetados de 64 bits, igual que el intérprete:

| Valor | Representación |
|---|---|
| `nulo` | 0 |
| `falso` / `verdadero` | 2 / 4 |
| entero | n·2 + 1 (impar) |
| texto, lista, mapa, flotante | caja `[tipo][dato]` |

- `runtime/map.cfv`: tabla hash FNV-1a con direccionamiento abierto,
  crecimiento ×2 con 2/3 de carga, lápidas para borrar.
- `runtime/dyn.cfv`: operadores, indexación, `para … en`, `mostrar`,
  `longitud`, `agregar`, `claves`, `tiene_clave`, `a_texto`, `a_numero`,
  `piso`, `lista_rango`, etc. Las claves se recorren en orden, como en el
  intérprete.
- Sintaxis nueva en el compilador: `[..]`, `{..}`, `x[i]`, `x[i][j] = v`,
  `x.metodo(..)`, `para x en c`, `romper`, `continuar`, `+= -= *= /= %=`,
  `sino si`, flotantes literales, `nulo` e `importar "modulo"`.

```sh
cforge-self -o prog --stdlib stdlib runtime/{sys_linux,mem,str,vec,io,f64,map}.cfv \
    --puente runtime/dyn.cfv --dinamico prog.cfv
```

Verificado en CI: `tests/nativo/06_colecciones.cfv` produce exactamente la
salida del intérprete, y `tests/cfv/03, 06, 10 y 16` (colecciones y sus
bibliotecas) pasan compiladas a ELF sin libc. Estado de la suite completa:
7 de 25 pruebas ya compilan nativas; el resto espera los bloques 2 a 4
(clases, closures, errores, `extern`, más funciones de la biblioteca).

### Bloque 2: clases, estructuras, métodos e inglés en el compilador autoalojado ✅

- `clase X [extiende P] [implementa I] { sea campo = v  funcion metodo(..) {..} }`,
  `estructura P { x: numero  y: numero }` (constructor posicional),
  `interfaz`, `abstracto`, `privado`/`publico`/`estatico`.
- Una instancia es un mapa con `"__clase"` (igual que el intérprete). Los
  campos se inicializan desde el padre hacia la clase hija; `Nombre(args)`
  llama a `constructor` propio o heredado.
- Métodos: despacho dinámico por la tabla de clases que el compilador deja en
  el ejecutable (`call rax`), subiendo por la cadena de herencia;
  `super.metodo(..)` se resuelve al compilar. Si el valor no es una instancia,
  `x.f(a)` equivale a `f(x, a)` (por ejemplo `lista.agregar(v)`).
- Asignación a campos e índices encadenados: `esto.a["k"].b = v`, también con
  `+= -= *= /= %=`.
- Palabras clave en inglés (`class`, `function`/`func`/`fn`, `let`/`var`, `if`,
  `else`, `for`, `in`, `return`, `true`, `false`, `null`, `this`/`self`, …) y
  nombres de funciones en inglés (`append`, `length`, `upper`, …). Si el
  programa está escrito mayormente en inglés, los valores se imprimen en
  inglés (`true`, `null`).
- Los errores de compilación indican `archivo.cfv:línea`.

### Bloque 3: funciones anónimas, globales y errores en el compilador autoalojado ✅

- `funcion(x) { ... }` como valor, con captura por referencia: si una función
  contiene funciones anónimas, sus variables viven en celdas del heap
  (`mem.cfv`) y los cierres las comparten. `sea f = funcion(..) { f(..) }`
  permite recursión. Las funciones con nombre también son valores.
- Las variables de nivel superior son globales visibles desde las funciones.
- `intentar { } capturar (e) { } finalmente { }` y `lanzar valor`: el runtime
  guarda `rsp`/`rbp`/destino y `lanzar` restaura ese marco. Los errores del
  lenguaje (división por cero, índice inválido, `afirmar`) se pueden capturar.
  `retornar`, `romper` y `continuar` cierran los bloques `intentar` abiertos.
  A diferencia del intérprete, `capturar` recibe el valor lanzado tal cual
  (no convertido a texto).
- `a ?? b`, argumentos faltantes = `nulo`, `runtime/lenguaje.cfv` (biblioteca
  del lenguaje en C-Forge: `mapear`, `filtrar`, `reducir`, `tarea`, `esperar`).

### Bloque 4A: biblioteca estándar nativa ✅ (24 de 25 pruebas)

- `runtime/biblioteca.cfv` (modo puente, sin libc): matemática con series
  propias (`seno`, `coseno`, `tangente`, `arcoseno`, `arccoseno`,
  `arcotangente`, `exponencial`, `logaritmo`, `potencia`, `raiz` con `sqrtsd`,
  `redondear`, `absoluto`, `minimo`, `maximo`, `aleatorio`), texto
  (`texto_reemplazar`, `texto_dividir`, `texto_unir`, `texto_recortar`,
  `subtexto`, `contiene`, `caracter`, UTF-8), Base64, URL, SHA-256 y MD5,
  archivos, tiempo con `clock_gettime` (UTC), `sys_info` con
  `sched_getaffinity`, rutas, `insertar`/`eliminar`.
- `runtime/lenguaje.cfv` (C-Forge completo): JSON (`json_serializar`,
  `json_bonito`, `json_parsear` con escapes `\u`, exponentes) y un motor de
  expresiones regulares con retroceso (clases, grupos, alternativas,
  cuantificadores `* + ? {m,n}`, anclas).
- Interpolación de textos `"Hola {nombre}"`, `si(c, a, b)` perezoso y números
  impresos como el intérprete (6 cifras significativas, `%g`).
- Los módulos importados se ejecutan antes que el archivo que los importa.
- Diferencias con el intérprete: `md5` da el MD5 real (el intérprete devolvía
  SHA-256) y `fecha_ahora` usa UTC.

### Bloque 4B: `extern` nativo con enlace dinámico ELF ✅ (25 de 25 pruebas)

`extern "libc" funcion strlen(s: texto): largo` hace que `cforge_self` genere
un ELF dinámico por sí mismo, sin `gcc` ni `ld`:

- encabezados `PT_INTERP` (`/lib64/ld-linux-x86-64.so.2`), `PT_LOAD` y
  `PT_DYNAMIC`; tablas `DT_NEEDED`, `.dynstr`, `.dynsym`, `.hash` y
  relocaciones `R_X86_64_GLOB_DAT` hacia una GOT, con `DT_BIND_NOW`;
- símbolos débiles: si un símbolo no existe, la declaración lanza un error
  capturable que lo nombra;
- envolturas con la ABI System V AMD64: enteros en `rdi rsi rdx rcx r8 r9`,
  flotantes en `xmm0`–`xmm7`, pila alineada a 16, `al` = registros vectoriales;
- tipos: `entero` (32 bits), `largo`/`puntero` (64), `numero` (double),
  `texto` (`char*`), `booleano`, `nulo`;
- `"libc"` → `libc.so.6`, `"libm"` → `libm.so.6`, `"sqlite3"` →
  `libsqlite3.so`, o una ruta `.so`.

Los programas sin `extern` siguen siendo estáticos y sin libc.

### Bloque 5: `cforge` 100 % C-Forge en Linux ✅

- `bootstrap/nativo/cforge_cli.cfv` es el comando `cforge` oficial en Linux
  x86-64: `cforge archivo.cfv`, `run`, `build [-o]`, `check`, `--version`.
  Compila a un ELF nativo y lo ejecuta (`fork` + `execve` + `wait4`). El
  runtime va incrustado (`embebido.cfv`, generado por `embeber.cfv`), así el
  binario (~236 KB, estático, sin libc) no depende de archivos externos; la
  biblioteca estándar se busca en `$CFORGE_STDLIB` o junto al ejecutable.
- Cadena: semilla → s1 → s2 → **s2 = s3** (`make cforge-nativo`).
- **Semilla** `bootstrap/semilla/cforge-linux-x64` (+ SHA-256): reconstruye
  `cforge` sin compiladores en el `PATH`; `make semilla-check` comprueba que
  reproduce exactamente al compilador actual.
- Releases: `cforge` nativo para Linux (x64, ARM64), Windows x64 y macOS
  (Apple Silicon, Intel). Desde 4.1 los 35 módulos de `stdlib/` cargan con el
  compilador nativo (red y HTTPS, SQLite, OpenGL 3.3, crypto, …).

**Cobertura actual del compilador nativo:** 25/25 pruebas de `tests/cfv`,
32/32 ejemplos del sitio y 22/22 programas de `ejemplos/`.

### Sprint 22/22: `ejemplos/` completo con el compilador nativo ✅

- **`extern` genérico:** cualquier biblioteca compartida (`"SDL2"`,
  `"sqlite3"`, `"ssl"`, una ruta `.so`), resuelta con `dlopen`/`dlsym` en el
  primer uso (búsqueda `lib<nombre>.so*` con `getdents64`). Si falta la
  biblioteca o el símbolo, el error es capturable. Declaraciones repetidas
  reutilizan la primera. Intrínseco `__ccall` para punteros a funciones C.
- **Concurrencia real:** `tarea(f)`/`hilo(f)` crean hilos con `clone` (pila
  propia de 8 MiB alineada, con su pila de manejadores de errores);
  `esperar(t[, ms])` usa `futex` sobre `CLONE_CHILD_CLEARTID` y relanza el
  error del hilo. `canal_nuevo/enviar/recibir/tam/cerrar` y
  `mutex_crear/bloquear/desbloquear` con `futex`. El asignador de memoria se
  protege con `xchg` atómico. El proceso termina con `exit_group`.
- **Servidor HTTP** (`servidor_http_escuchar/solicitud/responder/cerrar`)
  con syscalls de sockets; lee el cuerpo según `Content-Length`.
- **SDL2** (`runtime/sdl.cfv`, escrito en C-Forge sobre `extern`): se incluye
  solo si el programa usa `sdl_`; SDL2_ttf/SDL2_image opcionales.
- **Sintaxis:** `x?.campo`, ternario `c ? a : b`, `expr?` (propaga un
  Resultado con error u Opción vacía), genéricos `<T>` en clases, funciones,
  tipos e instancias, parámetros por defecto y variádicos (`...resto`),
  `inseguro { }` con punteros `@x`, `*(p + i)` verificados, atributos
  `#[Ruta("/r", "POST")]` con `rutas_compiladas()`, `.longitud`,
  importaciones relativas al archivo que importa.
- Verificación sin el intérprete: `tests/nativo/ejemplos.sh` compara con
  `ejemplos/salidas/` (generadas con el intérprete de referencia), prueba el
  servidor con `curl` y el ciclo de SDL.

### Windows x86-64 (PE64) 100 % C-Forge ✅

- `cforge build archivo.cfv --target windows` (o `-o x.exe --target windows`
  en el modo de bajo nivel) genera ejecutables PE32+ x86-64 desde cualquier
  plataforma: una sección RWX con código, datos y la tabla de importaciones
  (IAT de `kernel32.dll`, `ws2_32.dll`), ImageBase fija sin relocaciones.
- `__winapi("dll", "Función", args…)`: llamadas con la ABI x64 de Windows
  (rcx/rdx/r8/r9, 32 bytes de sombra, pila alineada).
- `runtime/sys_windows.cfv` (archivos, memoria con `VirtualAlloc`,
  argumentos de `GetCommandLineA`, procesos con `CreateProcessA`, entorno) y
  `runtime/sys_windows_ext.cfv` (tiempo, `Sleep`, directorios, hilos con
  `CreateThread` y un trampolín que cambia a la pila propia del hilo, red con
  Winsock, `LoadLibraryA`/`GetProcAddress`). `extern` usa la ABI de Windows;
  `"libc"`/`"libm"` → `msvcrt.dll`, `"SDL2"` → `SDL2.dll`.
- El runtime y la biblioteca acceden al sistema solo mediante funciones
  `sys_*` (`sys_linux*.cfv` / `sys_windows*.cfv`), elegidas por plataforma.
- CI en Windows real (`windows-nativo.yml`): `cforge.exe` se compila a sí
  mismo y **Stage 2 = Stage 3 = el `.exe` compilado de forma cruzada desde
  Linux**, byte por byte; 25/25 `tests/cfv`, 32/32 ejemplos del sitio y
  22/22 `ejemplos/` (servidor HTTP con Winsock, SDL2).

### macOS x86-64 (Mach-O) 100 % C-Forge ✅

- `cforge build archivo.cfv --target macos` genera ejecutables Mach-O x86-64
  desde Linux, Windows o macOS: `__PAGEZERO`, `__TEXT` (r-x), `__DATA`
  (datos, punteros de libSystem y globales) y `__LINKEDIT` con las
  instrucciones de enlace de `dyld` (`LC_DYLD_INFO_ONLY`), `LC_MAIN` y
  `LC_LOAD_DYLIB /usr/lib/libSystem.B.dylib`. Carga fija en 0x400000.
- `__libsistema("función", args…)`: llamada SysV a una función de
  libSystem (la interfaz estable de macOS; no se usan syscalls directas).
- `runtime/sys_macos.cfv` (archivos, `mmap`, argumentos y entorno que entrega
  `dyld` a la entrada, `fork`/`execve`/`waitpid`, `_NSGetExecutablePath`) y
  `runtime/sys_macos_ext.cfv` (`clock_gettime`, `usleep`, `opendir`/`readdir`,
  hilos con `pthread_create` y el trampolín de pila propia, sockets BSD,
  `dlopen`/`dlsym`). `extern` usa SysV; `"libc"`/`"libm"` →
  `libSystem.B.dylib`, `"SDL2"` → `libSDL2.dylib`.
- CI en macOS real (`macos-nativo.yml`, Intel y Apple Silicon con Rosetta 2):
  **Stage 2 = Stage 3 = el Mach-O compilado de forma cruzada desde Linux**,
  byte por byte; 25/25 `tests/cfv`, 32/32 ejemplos del sitio y 22/22
  `ejemplos/` (servidor HTTP, hilos, SDL2 de Homebrew).

### Gestor de paquetes (`cforge.toml`) ✅

```toml
[paquete]
nombre = "mi_app"
version = "0.1.0"
principal = "principal.cfv"

[dependencias]
json = "usuario/repo@v1.2"     # rama, etiqueta o nada (rama por defecto)
```

- `cforge init [nombre]` crea `cforge.toml`, `principal.cfv` y `.gitignore`.
- `cforge add usuario/repo[@ref] [--como alias]` descarga el paquete de
  GitHub (clon superficial con `git`) a la caché global
  `$CFORGE_HOME/paquetes/usuario/repo/ref` (por defecto `~/.cforge`), lo
  agrega a `[dependencias]` y escribe `cforge.lock` con el commit exacto de
  cada dependencia, también de las transitivas. `cforge remove alias` y
  `cforge install` (descarga lo que falte) completan el ciclo.
- `importar "alias"` carga el archivo principal del paquete (`principal` de
  su `cforge.toml`, o `repo.cfv`, `lib.cfv`, `principal.cfv`);
  `importar "alias/modulo"` carga `modulo.cfv` del paquete. Orden de
  búsqueda: archivo local, paquetes del proyecto, biblioteca estándar.
- `cforge run`, `build` y `check` sin archivo usan el `principal` del
  proyecto (buscando `cforge.toml` hacia arriba desde el directorio actual).
- `CFORGE_GIT_BASE` cambia el origen de las descargas (p. ej. un espejo o
  `file://` para pruebas: `tests/paquetes/prueba.sh`).

### `cforge fmt` y servidor de lenguaje (`cforge lsp`) ✅

- `cforge fmt [--check] [--stdout] [rutas]`: formatea en el lugar (sin
  rutas, todos los `.cfv` del proyecto). Sangría de 4 espacios por grupo
  abierto (un nivel por línea), continuación de expresiones, un espacio tras
  las comas, `si (`, `} sino {`, sin espacios finales y como máximo una
  línea en blanco seguida. No toca textos, comentarios ni la alineación de
  los comentarios. Conserva los tokens y es idempotente (probado con los
  234 `.cfv` del repositorio).
- `cforge lsp`: servidor LSP por stdio escrito en C-Forge. Diagnósticos con
  la línea exacta (ejecuta `cforge check --contenido … --diagnosticos …`
  con el texto sin guardar), autocompletado (documento, importaciones,
  paquetes, biblioteca del lenguaje y palabras clave), ir a la definición,
  información al pasar el cursor y formateo.
- Extensión de VS Code (`herramientas/vscode-cforgev`): cliente del LSP con
  `vscode-languageclient`; el CI publica el `.vsix` como artefacto.

### Apple: Xcode, iOS y Objective-C ✅

- `cforge build archivo.cfv --lib [-o libx.a | x.o] [--target T]` con
  `T` = `macos-arm64`, `ios-arm64` o `ios-sim-arm64`: Mach-O objeto ARM64
  (relocaciones `PAGE21`/`PAGEOFF12`/`UNSIGNED`, símbolos `_nombre`) dentro
  de un archivo estático `.a` (`__.SYMDEF SORTED`) y la cabecera C `x.h`.
- Se exportan las funciones marcadas con `#[Exportar]`; sus tipos salen de
  las anotaciones: `entero` → `int64_t`, `entero32` → `int32_t`, `numero` →
  `double`, `texto` → `const char *`, `booleano` → `bool`, sin resultado →
  `void`. Cada envoltura (ABI AAPCS64) usa su propia pila del lenguaje de
  8 MiB; la primera llamada ejecuta el código de nivel superior; las
  llamadas se serializan con un cerrojo.
- `cforge xcode-init [X.xcodeproj]`: regla de compilación de Xcode para
  `*.cfv` (Cmd + B / Cmd + R: `cforge build --lib` según `PLATFORM_NAME`),
  `CForge/CForge-Bridging-Header.h` para Swift, `HEADER_SEARCH_PATHS` y
  `CForge/CForge.xclangspec` (resaltado; Xcode no tiene soporte oficial para
  lenguajes de terceros, se instala en `~/Library/Developer/Xcode/Specifications`).
- `importar "apple"` (`stdlib/apple.cfv`): `objc_clase`, `objc_sel`,
  `objc_enviar(objeto, "selector:", args…)`, `ns_texto`, `texto_de_ns`,
  `lista_de_ns` sobre `objc_getClass`, `sel_registerName` y `objc_msgSend`.
- `extern "lib" funcion nombre(...): tipo como "símbolo"` declara varias
  firmas del mismo símbolo C. Los `puntero`/`largo` que no caben en un entero
  del lenguaje (tagged pointers de ARM64) viajan exactos en una caja.

### Capa intermedia y backend AArch64 ✅

- El compilador no emite bytes de máquina: pide operaciones de una máquina de
  pila (`bootstrap/nativo/gen.cfv`) que traduce cada backend:
  `gen_x64.cfv` (x86-64) y `gen_a64.cfv` (AArch64). La refactorización no
  cambió un solo byte de la salida x86-64 (228 binarios de referencia).
- AArch64: la pila del lenguaje vive en `x28` con el mismo marco que x86-64
  (`[x29 + 16]` = argumentos) y `sp` queda alineado a 16 para llamar a C;
  saltos condicionales de largo alcance (condición inversa + `b`).
- `--target macos-arm64`: Mach-O PIE en `0x100000000`, páginas de 16 KiB,
  `rebase` de `dyld` para los punteros de datos y **firma ad-hoc**
  `LC_CODE_SIGNATURE` (CodeDirectory 0x20400 con el SHA-256 de cada página,
  calculado por un SHA-256 escrito en C-Forge). `codesign -v` la acepta.
- `--target linux-arm64`: ELF AArch64 con `runtime/sys_linux_arm64*.cfv`
  (sin `extern` por ahora); `make linux-arm64-check` lo valida con qemu.
- CI en Apple Silicon real: **Stage 2 = Stage 3 = el Mach-O ARM64 compilado
  de forma cruzada desde Linux y desde Windows**, byte por byte; 25/25
  `tests/cfv`, 32/32 ejemplos del sitio y 22/22 `ejemplos/` (SDL2 incluido).

**Alcance:** el compilador autoalojado compila el lenguaje C-Forge completo
(clases, mapas, listas, cierres, excepciones, hilos, `extern`) a ELF, PE y
Mach-O. Desde 4.1 la biblioteca estándar está completa (HTTP/HTTPS, TCP, UDP,
DNS, SQLite, OpenGL 3.3, HMAC y AES). Pendiente: WebSocket real, un recolector
de basura para cadenas temporales y `cforge repl`.
