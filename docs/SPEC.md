# C-Forge — Especificación del lenguaje

Versión del documento: 3.7.3 · Extensión de archivos: **`.cfv`** · CLI: **`cforge`**

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
- Textos entre comillas dobles. `{expresión}` interpola; `\{` y `\}` son llaves
  literales. Escapes: `\n`, `\t`, `\"`, `\\`.
- Números decimales (`42`, `3.14`).

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
clase. Las anotaciones (`sea x: numero = 1`) se aceptan.

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
| `cforge build` con compilador 100 % C-Forge | 🛠️ |
| `cforge add usuario/repo`, `cforge.json` con dependencias | 📐 |
| LSP completo (diagnósticos, autocompletado, ir a definición) | 🛠️ |

---

## 13. Camino al compilador 100 % C-Forge

El ejecutable `cforge` publicado hoy está escrito en C++ (`cforgev.cpp`). El
objetivo es reemplazarlo por un compilador escrito en C-Forge que emita código
máquina directo. C++ queda solo como **Stage 0**: se usa una vez para arrancar,
como hicieron Go (desde C) y Rust (desde OCaml).

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

**Alcance honesto:** el compilador autoalojado compila el *dialecto nativo*
(enteros de 64 bits, funciones, recursión, condiciones, ciclos, textos
literales e intrínsecos). El lenguaje C-Forge completo (clases, mapas,
listas literales, closures, excepciones, `extern`) todavía se ejecuta con
`cforgev.cpp`. Retirar ese binario requiere llevar cada característica del
lenguaje al compilador autoalojado, sobre el runtime de `runtime/`.

Cuando el compilador Core compile sus propias fuentes con su backend ELF y el
resultado sea idéntico byte por byte (Stage 2 = Stage 3, sin gcc ni clang en
el `PATH`), C-Forge será autónomo en Linux; luego Mach-O y PE.
