# ── C-Forge Makefile ───────────────────────────────────────────────────────────
# C-Forge es 100 % C-Forge: el compilador, el runtime y las herramientas están
# escritos en C-Forge y se construyen a sí mismos. La raíz de confianza es la
# semilla bootstrap/semilla/cforge-linux-x64 (un cforge para Linux x86-64),
# que compila las fuentes; no hace falta C++, libc ni enlazador.
#
#   make                 cforge (Linux x86-64) desde la semilla
#   make release-check   gate completo antes de publicar
#   make install         instalar en $(PREFIX)
#   make help            todas las órdenes

TARGET   := cforge
PREFIX   ?= /usr/local
VERSION  := 4.4.0
UNAME    := $(shell uname -s)
ARCH     := $(shell uname -m)

# ── Fuentes ────────────────────────────────────────────────────────────────────
RUNTIME_NATIVO := runtime/sys_linux.cfv runtime/mem.cfv runtime/str.cfv \
	runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
RUNTIME_LENGUAJE := $(RUNTIME_NATIVO) runtime/sys_linux_ext.cfv runtime/map.cfv --puente runtime/dyn.cfv runtime/biblioteca.cfv runtime/cripto.cfv runtime/medios.cfv --lenguaje runtime/lenguaje.cfv
PRUEBAS_LENGUAJE_NATIVAS := $(basename $(notdir $(wildcard tests/cfv/*.cfv)))
FUENTES_COMPILADOR := $(RUNTIME_NATIVO) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/gen_wasm.cfv bootstrap/nativo/biblioteca_c.cfv
FUENTES_CFORGE := $(FUENTES_COMPILADOR) bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
EMBEBIDO_ARGS := --nativo $(RUNTIME_NATIVO) runtime/sys_linux_ext.cfv runtime/sys_linux_arm64.cfv runtime/sys_linux_arm64_ext.cfv runtime/sys_windows.cfv runtime/sys_windows_ext.cfv runtime/sys_macos.cfv runtime/sys_macos_ext.cfv runtime/map.cfv --puente runtime/dyn.cfv runtime/biblioteca.cfv runtime/cripto.cfv runtime/medios.cfv --lenguaje runtime/lenguaje.cfv --opcional runtime/sdl.cfv runtime/gl3d.cfv --recurso runtime/wasm_cargador.js
SEMILLA := bootstrap/semilla/cforge-linux-x64


.PHONY: all build install uninstall check test stdlib-load-check cli-check \
	malformed-check install-check smoke-test release-check bench clean help \
	cforge-nativo embebido semilla semilla-check cforge-desde-semilla nativo-check \
	autoalojado-check windows-cruzado macos-cruzado macos-arm64-cruzado linux-arm64-cruzado linux-arm64-check

## ── Construcción ───────────────────────────────────────────────────────────────

all: build

## cforge (Linux x86-64) compilado por la semilla.
build: cforge-desde-semilla

cforge-desde-semilla:
	@cp $(SEMILLA) ./.semilla && chmod +x ./.semilla
	@./.semilla -o $(TARGET) $(FUENTES_CFORGE) >/dev/null && rm -f ./.semilla
	@echo "  ✓ cforge compilado por la semilla: $$(./$(TARGET) --version)"

## ./cforge-nativo verificado: semilla → s1 → s2 → s3, con s2 = s3.
cforge-nativo:
	@set -e; dir=$$(mktemp -d /tmp/cforge-nativo.XXXXXX); \
	cp $(SEMILLA) "$$dir/semilla"; chmod +x "$$dir/semilla"; \
	env -i PATH=/nonexistent "$$dir/semilla" -o "$$dir/s1" $(FUENTES_CFORGE) >/dev/null; \
	env -i PATH=/nonexistent "$$dir/s1" -o "$$dir/s2" $(FUENTES_CFORGE) >/dev/null; \
	env -i PATH=/nonexistent "$$dir/s2" -o "$$dir/s3" $(FUENTES_CFORGE) >/dev/null; \
	cmp "$$dir/s2" "$$dir/s3"; \
	cp "$$dir/s3" cforge-nativo; rm -rf "$$dir"; \
	echo "  ✓ cforge-nativo: Stage 2 = Stage 3, $$(wc -c < cforge-nativo) bytes, sin libc ni C++"

## Regenera el runtime incrustado (tras cambiar runtime/*.cfv o VERSION).
embebido:
	@set -e; dir=$$(mktemp -d /tmp/cforge-emb.XXXXXX); \
	cp $(SEMILLA) "$$dir/semilla"; chmod +x "$$dir/semilla"; \
	"$$dir/semilla" -o "$$dir/embeber" $(RUNTIME_NATIVO) bootstrap/nativo/embeber.cfv >/dev/null; \
	"$$dir/embeber" bootstrap/nativo/embebido.cfv $(VERSION) $(EMBEBIDO_ARGS); rm -rf "$$dir"

## Actualiza la semilla con el cforge actual (tras cambiar el compilador).
semilla: cforge-nativo
	@mkdir -p bootstrap/semilla
	@cp cforge-nativo $(SEMILLA)
	@sha256sum $(SEMILLA) | sed 's#bootstrap/semilla/##' > $(SEMILLA).sha256
	@echo "  ✓ semilla actualizada: $$(cat $(SEMILLA).sha256)"

## La semilla reproduce exactamente al compilador actual (y a sí misma).
semilla-check: cforge-nativo
	@set -e; (cd bootstrap/semilla && sha256sum -c cforge-linux-x64.sha256 >/dev/null); \
	if ! cmp -s cforge-nativo $(SEMILLA); then echo "  ✗ la semilla está desactualizada: ejecuta make semilla"; exit 1; fi; \
	echo "  ✓ semilla → cforge: idéntico byte por byte (s1 = s2 = s3 = semilla)"

## Dialecto nativo: ejecutables ELF estáticos sin libc ni enlazador.
nativo-check: cforge-nativo
	@set -e; dir=$$(mktemp -d /tmp/cforge-n.XXXXXX); \
	for prueba in 01_memoria 02_textos 03_listas 04_prueba_de_fuego 05_lexer; do \
		extra=""; [ "$$prueba" = 05_lexer ] && extra=bootstrap/nativo/lexer.cfv; \
		env PATH=/nonexistent ./cforge-nativo -o "$$dir/$$prueba" $(RUNTIME_NATIVO) $$extra tests/nativo/$$prueba.cfv >/dev/null; \
		if ldd "$$dir/$$prueba" >/dev/null 2>&1; then echo "  ✗ $$prueba enlaza librerías dinámicas"; exit 1; fi; \
	done; \
	for prueba in 01_memoria 02_textos 03_listas; do "$$dir/$$prueba" | diff -u tests/nativo/$$prueba.salida -; done; \
	"$$dir/04_prueba_de_fuego" tests/nativo/fixtures/entrada.cfv "$$dir/reporte" > "$$dir/04.real"; \
	diff -u tests/nativo/04_prueba_de_fuego.salida "$$dir/04.real"; \
	diff -u tests/nativo/fixtures/reporte.esperado "$$dir/reporte"; \
	"$$dir/05_lexer" runtime/str.cfv "$$dir/lex" >/dev/null; test -s "$$dir/lex"; \
	rm -rf "$$dir"; \
	echo "  ✓ Dialecto nativo ELF sin libc: memoria, textos, listas, archivos, f64 y lexer"

## Pruebas del cforge nativo: dialecto nativo, lenguaje completo y CLI.
autoalojado-check: cforge-nativo
	@set -e; dir=$$(mktemp -d /tmp/cforge-self.XXXXXX); C=./cforge-nativo; \
	for prueba in 01_memoria 02_textos 03_listas; do \
		env -i $$C -o "$$dir/$$prueba" $(RUNTIME_NATIVO) tests/nativo/$$prueba.cfv >/dev/null; \
		"$$dir/$$prueba" | diff -u tests/nativo/$$prueba.salida -; \
	done; \
	env -i $$C -o "$$dir/fuego" $(RUNTIME_NATIVO) tests/nativo/04_prueba_de_fuego.cfv >/dev/null; \
	"$$dir/fuego" tests/nativo/fixtures/entrada.cfv "$$dir/reporte" >/dev/null; \
	diff -u tests/nativo/fixtures/reporte.esperado "$$dir/reporte"; \
	env -i $$C -o "$$dir/mapa" $(RUNTIME_NATIVO) runtime/map.cfv tests/nativo/07_mapa.cfv >/dev/null; \
	"$$dir/mapa" | diff -u tests/nativo/07_mapa.salida -; \
	for prueba in 06_colecciones 08_clases 09_cierres_errores 10_biblioteca 11_extern 12_hilos; do \
		env -i CFORGE_STDLIB=stdlib $$C tests/nativo/$$prueba.cfv | diff -u tests/nativo/$$prueba.salida -; \
	done; \
	for prueba in $(PRUEBAS_LENGUAJE_NATIVAS); do \
		env -i CFORGE_STDLIB=stdlib $$C tests/cfv/$$prueba.cfv | grep -q '^\[OK\]' || { echo "  ✗ tests/cfv/$$prueba.cfv"; exit 1; }; \
	done; \
	for ejemplo in site/ejemplos/*.cfv site/ejemplos/en/*.cfv; do \
		env -i CFORGE_STDLIB=stdlib $$C $$ejemplo | diff -u $${ejemplo%.cfv}.salida - || { echo "  ✗ $$ejemplo"; exit 1; }; \
	done; \
	env -i CFORGE_STDLIB=stdlib $$C build tests/cfv/01_nucleo.cfv -o "$$dir/nucleo" >/dev/null; "$$dir/nucleo" | grep -q '^\[OK\]'; \
	env -i $$C check tests/cfv/08_clases.cfv >/dev/null; \
	env -i $$C --version | grep -q "$(VERSION)"; \
	sh tests/nativo/ejemplos.sh $$C; \
	sh tests/paquetes/prueba.sh $$C; \
	$$C fmt --stdout tests/formato/entrada.cfv | cmp - tests/formato/esperado.cfv; \
	$$C fmt --check tests/formato/esperado.cfv; \
	echo "  ✓ cforge fmt: salida esperada e idempotente"; \
	echo "  ✓ Suite del lenguaje con cforge nativo: $(words $(PRUEBAS_LENGUAJE_NATIVAS)) pruebas, ejemplos del sitio, ejemplos/ y CLI (run, build, check)"

## ── Windows x86-64 (PE64), compilado de forma cruzada desde Linux ───────
RUNTIME_WINDOWS := runtime/sys_windows.cfv runtime/mem.cfv runtime/str.cfv runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
FUENTES_CFORGE_WINDOWS := $(RUNTIME_WINDOWS) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/gen_wasm.cfv bootstrap/nativo/biblioteca_c.cfv bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
windows-cruzado: cforge-nativo
	@set -e; rm -rf dist-windows; mkdir -p dist-windows/pruebas; \
	./cforge-nativo -o dist-windows/cforge.exe --target windows $(FUENTES_CFORGE_WINDOWS) >/dev/null; \
	for prueba in 01_memoria 02_textos 03_listas 04_prueba_de_fuego; do \
		./cforge-nativo -o dist-windows/pruebas/$$prueba.exe --target windows $(RUNTIME_WINDOWS) tests/nativo/$$prueba.cfv >/dev/null; \
	done; \
	sha256sum dist-windows/cforge.exe; \
	echo "  ✓ cforge.exe (PE64) y pruebas compiladas para Windows desde Linux"

## ── macOS x86-64 (Mach-O), compilado de forma cruzada ───────────────────
RUNTIME_MACOS := runtime/sys_macos.cfv runtime/mem.cfv runtime/str.cfv runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
FUENTES_CFORGE_MACOS := $(RUNTIME_MACOS) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/gen_wasm.cfv bootstrap/nativo/biblioteca_c.cfv bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
macos-cruzado: cforge-nativo
	@set -e; rm -rf dist-macos; mkdir -p dist-macos/pruebas; \
	./cforge-nativo -o dist-macos/cforge --target macos $(FUENTES_CFORGE_MACOS) >/dev/null; \
	for prueba in 01_memoria 02_textos 03_listas 04_prueba_de_fuego; do \
		./cforge-nativo -o dist-macos/pruebas/$$prueba --target macos $(RUNTIME_MACOS) tests/nativo/$$prueba.cfv >/dev/null; \
	done; \
	sha256sum dist-macos/cforge; \
	echo "  ✓ cforge (Mach-O x86-64) y pruebas compiladas para macOS desde Linux"

## ── macOS ARM64 (Mach-O PIE firmado), compilado de forma cruzada ─────────
macos-arm64-cruzado: cforge-nativo
	@set -e; rm -rf dist-macos-arm64; mkdir -p dist-macos-arm64/pruebas; \
	./cforge-nativo -o dist-macos-arm64/cforge --target macos-arm64 $(FUENTES_CFORGE_MACOS) >/dev/null; \
	for prueba in 01_memoria 02_textos 03_listas 04_prueba_de_fuego; do \
		./cforge-nativo -o dist-macos-arm64/pruebas/$$prueba --target macos-arm64 $(RUNTIME_MACOS) tests/nativo/$$prueba.cfv >/dev/null; \
	done; \
	sha256sum dist-macos-arm64/cforge; \
	echo "  ✓ cforge (Mach-O ARM64 firmado) y pruebas compiladas para Apple Silicon desde Linux"

## ── Linux ARM64: cforge compilado de forma cruzada ──────────────────────
linux-arm64-cruzado: cforge-nativo
	@set -e; rm -rf dist-linux-arm64; mkdir -p dist-linux-arm64; \
	./cforge-nativo -o dist-linux-arm64/cforge --target linux-arm64 $(RUNTIME_LINUX_ARM64) bootstrap/nativo/lexer.cfv $(filter-out $(RUNTIME_NATIVO) bootstrap/nativo/lexer.cfv,$(FUENTES_CFORGE)) >/dev/null; \
	sha256sum dist-linux-arm64/cforge; \
	echo "  ✓ cforge (ELF AArch64) compilado para Linux ARM64 desde Linux x64"

## ── Linux ARM64: compilación cruzada y pruebas con qemu-aarch64 ──────────
RUNTIME_LINUX_ARM64 := runtime/sys_linux_arm64.cfv runtime/mem.cfv runtime/str.cfv runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
linux-arm64-check: cforge-nativo
	@set -e; command -v qemu-aarch64 >/dev/null || { echo "  (falta qemu-aarch64)"; exit 1; }; \
	dir=$$(mktemp -d); \
	for prueba in 01_memoria 02_textos 03_listas; do \
		./cforge-nativo -o $$dir/$$prueba --target linux-arm64 $(RUNTIME_LINUX_ARM64) tests/nativo/$$prueba.cfv >/dev/null; \
		qemu-aarch64 $$dir/$$prueba | diff -u tests/nativo/$$prueba.salida -; \
	done; \
	F="$(RUNTIME_LINUX_ARM64) bootstrap/nativo/lexer.cfv $(filter-out $(RUNTIME_NATIVO) bootstrap/nativo/lexer.cfv,$(FUENTES_CFORGE))"; \
	./cforge-nativo -o $$dir/cforge --target linux-arm64 $$F >/dev/null; \
	qemu-aarch64 $$dir/cforge -o $$dir/stage2 $$F >/dev/null; \
	qemu-aarch64 $$dir/stage2 -o $$dir/stage3 $$F >/dev/null; \
	cmp $$dir/cforge $$dir/stage2; cmp $$dir/stage2 $$dir/stage3; \
	rm -rf $$dir; echo "  ✓ Linux ARM64 (qemu): pruebas nativas y Stage 2 = Stage 3 = compilación cruzada"


## ── Pruebas ────────────────────────────────────────────────────────────────────

## Verificar que compilan la stdlib, las pruebas, los ejemplos y los benchmarks.
check: build
	@set -e; \
	for file in tests/cfv/*.cfv main.cfv ejemplos/*.cfv benchmarks/*.cfv; do \
		CFORGE_STDLIB=./stdlib ./$(TARGET) check "$$file" >/dev/null || { echo "  ✗ $$file"; exit 1; }; \
	done; \
	echo "  ✓ pruebas, ejemplos y benchmarks compilan"

## Ejecutar las pruebas escritas en C-Forge (cada una imprime [OK]).
test: build
	@set -e; total=0; \
	for file in tests/cfv/*.cfv; do \
		CFORGE_STDLIB=./stdlib ./$(TARGET) "$$file" | grep -q '^\[OK\]' || { echo "  ✗ $$file"; exit 1; }; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total archivos de prueba C-Forge aprobados"

## Importar y ejecutar cada módulo publicado de la biblioteca estándar.
stdlib-load-check: build
	@set -e; total=0; \
	for file in stdlib/*.cfv; do \
		module=$$(basename "$$file" .cfv); \
		if [ "$$module" = apple ] && [ "$(UNAME)" != Darwin ]; then continue; fi; \
		printf 'importar "%s"\n' "$$module" > /tmp/cforge-load-$$module.cfv; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) /tmp/cforge-load-$$module.cfv >/dev/null || { echo "  ✗ stdlib/$$module.cfv"; exit 1; }; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total módulos de la stdlib cargados (todos)"

## Módulos de la stdlib con salida esperada (SQLite del sistema).
stdlib-check: build
	@set -e; dir=$$(mktemp -d /tmp/cforge-db.XXXXXX); \
	(cd $$dir && CFORGE_STDLIB=$(CURDIR)/stdlib $(CURDIR)/$(TARGET) $(CURDIR)/tests/db/prueba.cfv) | diff -u tests/db/prueba.salida - || { echo "  ✗ tests/db"; exit 1; }; \
	(cd $$dir && CFORGE_STDLIB=$(CURDIR)/stdlib $(CURDIR)/$(TARGET) $(CURDIR)/tests/db/completa.cfv) | grep -q '^\[OK\]' || { echo "  ✗ tests/db/completa"; exit 1; }; \
	rm -rf $$dir; \
	echo "  ✓ db: SQLite (CRUD, ?N y :nombre, BLOB, transacciones anidadas, pool, inyección bloqueada)"; \
	for suite in graficos juego; do \
		CFORGE_STDLIB=./stdlib ./$(TARGET) tests/$$suite/prueba.cfv | diff -u tests/$$suite/prueba.salida - || { echo "  ✗ tests/$$suite"; exit 1; }; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) build tests/$$suite/prueba.cfv --release -o /tmp/cforge-$$suite >/dev/null; \
		(cd tests/$$suite && /tmp/cforge-$$suite) | diff -u tests/$$suite/prueba.salida - || { echo "  ✗ tests/$$suite (--release)"; exit 1; }; \
		CFORGE_GC_ESTRES=1 CFORGE_STDLIB=./stdlib ./$(TARGET) tests/$$suite/prueba.cfv | diff -u tests/$$suite/prueba.salida - >/dev/null || { echo "  ✗ tests/$$suite (GC en estrés)"; exit 1; }; \
	done; \
	echo "  ✓ gráficos: PNG/JPEG/BMP, zlib, TrueType, render 2D/3D y audio idénticos bit a bit"; \
	echo "  ✓ juego: física 2D/3D, colisiones, entrada y partículas"; \
	(cd tests/seguridad && CFORGE_STDLIB=../../stdlib ../../$(TARGET) prueba.cfv) | diff -u tests/seguridad/prueba.salida - || { echo "  ✗ tests/seguridad"; exit 1; }; \
	(cd tests/seguridad && CFORGE_GC_ESTRES=1 CFORGE_STDLIB=../../stdlib ../../$(TARGET) prueba.cfv) | diff -u tests/seguridad/prueba.salida - >/dev/null || { echo "  ✗ tests/seguridad (GC en estrés)"; exit 1; }; \
	echo "  ✓ seguridad: imágenes y fuentes hostiles, bombas de compresión, lecturas fuera de rango y secretos"

## Recolector de basura: memoria acotada en un programa largo y la suite
## completa recolectando cada 64 KiB (CFORGE_GC_ESTRES) para detectar raíces
## perdidas.
gc-check: build
	@set -e; CFORGE_STDLIB=./stdlib ./$(TARGET) tests/memoria/prueba.cfv | grep -q '^\[OK\]' || { echo "  ✗ tests/memoria"; exit 1; }; \
	CFORGE_STDLIB=./stdlib ./$(TARGET) tests/memoria/arena_llena.cfv | grep -q '^\[OK\]' || { echo "  ✗ tests/memoria/arena_llena"; exit 1; }; \
	for file in tests/cfv/*.cfv; do \
		CFORGE_GC_ESTRES=1 CFORGE_STDLIB=./stdlib ./$(TARGET) "$$file" | grep -q '^\[OK\]' || { echo "  ✗ $$file (GC en estrés)"; exit 1; }; \
	done; \
	echo "  ✓ recolector: 2 M iteraciones con arena < 50 MB, arenas llenas sin corrupción y suite completa en modo estrés"

## Verificador de tipos: 19 errores detectados al compilar y un programa
## con tipos anotados e inferidos que se acepta y ejecuta.
tipos-check: build
	@set -e; cd tests/tipos; \
	for f in error_*.cfv; do CFORGE_STDLIB=../../stdlib ../../$(TARGET) check $$f 2>&1 | head -1 | sed 's|^\[C-Forge\] ||'; done | diff -u errores.esperados - || { echo "  ✗ tests/tipos"; exit 1; }; \
	CFORGE_STDLIB=../../stdlib ../../$(TARGET) valido.cfv | grep -q '^\[OK\]'; \
	echo "  ✓ tipos: 19 errores detectados antes de ejecutar y un programa válido"

## WebAssembly (--target wasm): la suite del lenguaje en Node.js (menos
## extern C), extern "js" y llamadas desde JavaScript, y el .wasm publicado de
## la forja de c-forge.org igual al que sale de su fuente.
wasm-check: build
	@if ! command -v node >/dev/null 2>&1; then echo "  - wasm: sin Node.js, se omite"; exit 0; fi; \
	set -e; dir=$$(mktemp -d /tmp/cforge-wasm.XXXXXX); n=0; \
	for file in tests/cfv/*.cfv; do \
		case "$$file" in *24_extern_c*) continue ;; esac; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) build "$$file" --target wasm --release -o $$dir/p >/dev/null; \
		node tests/wasm/validar.mjs $$dir/p.wasm || { echo "  ✗ $$file: módulo .wasm inválido"; exit 1; }; \
		(cd tests/cfv && node $$dir/p.mjs) | grep -q '^\[OK\]' || { echo "  ✗ $$file en WebAssembly"; exit 1; }; \
		n=$$((n + 1)); \
	done; \
	for suite in graficos juego; do \
		CFORGE_STDLIB=./stdlib ./$(TARGET) build tests/$$suite/prueba.cfv --target wasm --release -o $$dir/s >/dev/null; \
		node tests/wasm/validar.mjs $$dir/s.wasm; \
		(cd tests/$$suite && node $$dir/s.mjs) | diff -u tests/$$suite/prueba.salida - >/dev/null || { echo "  ✗ tests/$$suite en WebAssembly"; exit 1; }; \
	done; \
	mkdir -p tests/wasm/salida; \
	CFORGE_STDLIB=./stdlib ./$(TARGET) build tests/wasm/interop.cfv --target wasm -o tests/wasm/salida/interop >/dev/null; \
	node tests/wasm/prueba.mjs; \
	./$(TARGET) build site/forja/forja.cfv --target wasm --release -o $$dir/forja >/dev/null; \
	cmp -s $$dir/forja.wasm site/assets/forja/forja.wasm && cmp -s $$dir/forja.mjs site/assets/forja/forja.mjs || { echo "  ✗ site/assets/forja desactualizado (cforge build site/forja/forja.cfv --target wasm --release -o site/assets/forja/forja)"; exit 1; }; \
	CFORGE_STDLIB=./stdlib ./$(TARGET) build ejemplos/web/particulas/particulas.cfv --target wasm --release -o $$dir/particulas >/dev/null; \
	CFORGE_STDLIB=./stdlib ./$(TARGET) build ejemplos/web/cubo3d/cubo3d.cfv --target wasm --release -o $$dir/cubo3d >/dev/null; \
	node tests/wasm/validar.mjs $$dir/particulas.wasm $$dir/cubo3d.wasm $$dir/forja.wasm; \
	rm -rf $$dir; \
	echo "  ✓ wasm: $$n suites del lenguaje + gráficos y juego en Node.js (módulos validados), interop con JavaScript y la forja del sitio"

## --release: "hola" < 60 KB, la suite completa sin el código muerto y el
## benchmark de enteros (holgura para máquinas lentas del CI).
release-modo-check: build
	@set -e; dir=$$(mktemp -d /tmp/cforge-rel.XXXXXX); \
	echo 'mostrar("hola")' > $$dir/hola.cfv; \
	./$(TARGET) build $$dir/hola.cfv --release -o $$dir/hola >/dev/null; \
	tam=$$(wc -c < $$dir/hola); [ "$$($$dir/hola)" = hola ]; \
	[ $$tam -lt 61440 ] || { echo "  ✗ hola --release: $$tam bytes"; exit 1; }; \
	for file in tests/cfv/*.cfv; do \
		CFORGE_STDLIB=./stdlib ./$(TARGET) build "$$file" --release -o $$dir/p >/dev/null; \
		(cd tests/cfv && $$dir/p) | grep -q '^\[OK\]' || { echo "  ✗ $$file con --release"; exit 1; }; \
	done; \
	./$(TARGET) build benchmarks/07_enteros_primos_fib.cfv --release -o $$dir/b >/dev/null; \
	ini=$$(date +%s%N); $$dir/b > $$dir/b.txt; ms=$$(( ($$(date +%s%N) - ini) / 1000000 )); \
	grep -q '^17984$$' $$dir/b.txt; grep -q '^832040$$' $$dir/b.txt; \
	[ $$ms -lt 250 ] || { echo "  ✗ benchmark de enteros: $$ms ms"; exit 1; }; \
	rm -rf $$dir; \
	echo "  ✓ --release: hola $$tam bytes, suite completa, benchmark de enteros $$ms ms"

## cforge repl: sesión guardada (sin la línea de versión).
repl-check: build
	@set -e; CFORGE_STDLIB=./stdlib ./$(TARGET) repl < tests/repl/entrada.txt 2>&1 | tail -n +2 | diff -u tests/repl/esperado.txt - || { echo "  ✗ cforge repl"; exit 1; }; \
	echo "  ✓ cforge repl: expresiones, funciones de varias líneas, errores y estado"

## Contrato público mínimo del CLI.
cli-check: build
	@set -e; \
	./$(TARGET) --version | grep -q "C-Forge $(VERSION)"; \
	./$(TARGET) --help | grep -q "cforge check"; \
	./$(TARGET) check tests/cfv/01_nucleo.cfv >/dev/null; \
	if ./$(TARGET) check /tmp/no-existe-cforge.cfv >/tmp/cforge-cli-out 2>/tmp/cforge-cli-err; then \
		echo "  ERROR el CLI aceptó un archivo inexistente"; exit 1; \
	fi; \
	grep -q "C-Forge" /tmp/cforge-cli-err; \
	echo "  ✓ contrato CLI verificado"

## Entradas dañadas deben fallar limpiamente, sin colgarse ni abortar.
malformed-check: build
	@set -e; total=0; \
	for source in '}{' '@@@@' 'sea =' 'mostrar("sin cerrar)' 'si (verdadero) {'; do \
		printf '%s\n' "$$source" > /tmp/cforge-malformed.cfv; \
		if timeout 20 ./$(TARGET) /tmp/cforge-malformed.cfv >/tmp/cforge-malformed-out 2>/tmp/cforge-malformed-err; then \
			echo "  ERROR entrada inválida aceptada: $$source"; exit 1; \
		fi; \
		grep -q "C-Forge" /tmp/cforge-malformed-err; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total entradas dañadas rechazadas limpiamente"

## Probar una instalación aislada sin modificar el sistema.
install-check: build
	@set -e; prefix=/tmp/cforge-install-check; \
	rm -rf "$$prefix"; \
	$(MAKE) install PREFIX="$$prefix" >/dev/null; \
	"$$prefix/bin/cforge" --version | grep -q "C-Forge $(VERSION)"; \
	"$$prefix/bin/cforge" tests/cfv/01_nucleo.cfv >/dev/null; \
	echo "  ✓ instalación aislada verificada en $$prefix"

## Smoke test de instalación (simula un usuario nuevo).
smoke-test: build
	@CFORGE_STDLIB=$(PWD)/stdlib bash tests/install-smoke/run_smoke.sh $(PWD)/$(TARGET)

## Gate único exigido antes de publicar una versión.
release-check: build nativo-check autoalojado-check semilla-check check test \
	stdlib-load-check stdlib-check repl-check gc-check tipos-check release-modo-check wasm-check cli-check malformed-check install-check smoke-test
	@echo ""
	@echo "  ✓ GATE DE ESTABILIDAD C-FORGE COMPLETO (100 % C-Forge)"

## ── Instalación ────────────────────────────────────────────────────────────────

install: build
	@install -d $(PREFIX)/bin $(PREFIX)/lib/cforge/stdlib
	@install -m 755 $(TARGET) $(PREFIX)/bin/cforge
	@install -m 644 stdlib/*.cfv $(PREFIX)/lib/cforge/stdlib/
	@install -d $(PREFIX)/share/cforge/completions
	@install -m 644 completions/* $(PREFIX)/share/cforge/completions/ 2>/dev/null || true
	@echo "  ✓ C-Forge instalado en $(PREFIX) (añade $(PREFIX)/bin al PATH)"

uninstall:
	@rm -f $(PREFIX)/bin/cforge
	@rm -rf $(PREFIX)/lib/cforge $(PREFIX)/share/cforge
	@echo "  ✓ C-Forge desinstalado"

## ── Varios ─────────────────────────────────────────────────────────────────────

bench: build
	@for b in benchmarks/*.cfv; do echo "  BENCH $$b"; CFORGE_STDLIB=./stdlib ./$(TARGET) "$$b" >/dev/null; done

clean:
	@rm -f $(TARGET) cforge-nativo .semilla
	@rm -rf dist-windows dist-macos dist-macos-arm64 dist-linux-arm64 pkg dist
	@echo "  ✓ limpio"

help:
	@echo "C-Forge $(VERSION) — 100 % C-Forge"
	@echo ""
	@echo "  make                    cforge desde la semilla"
	@echo "  make install            instalar en $(PREFIX)"
	@echo "  make release-check      gate completo"
	@echo "  make test | check       pruebas del lenguaje"
	@echo "  make semilla            actualizar la semilla tras cambiar el compilador"
	@echo "  make embebido           regenerar el runtime incrustado"
	@echo "  make windows-cruzado    cforge.exe (Windows x64) desde Linux"
	@echo "  make macos-cruzado      cforge para macOS Intel desde Linux"
	@echo "  make macos-arm64-cruzado  cforge para Apple Silicon desde Linux"
	@echo "  make linux-arm64-check  Linux ARM64 con qemu-aarch64"
