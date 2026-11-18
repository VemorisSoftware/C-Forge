# ── C-Forge Makefile ───────────────────────────────────────────────────────────
# Compila e instala el motor autónomo de C-Forge.
# C++ se usa únicamente como bootstrap del ejecutable nativo. La biblioteca
# estándar, las pruebas y los programas distribuidos usan archivos .cfv.

CXX      ?= g++
CXXFLAGS := -std=c++20 -O2 -Wall -Wextra -Wpedantic
INCLUDES := -I. -I./include
LIBS     := -lpthread -ldl
TARGET   := cforge
SRC      := cforgev.cpp
PREFIX   ?= /usr/local
VERSION  := 3.7.3

# Detección de plataforma
UNAME := $(shell uname -s)
ARCH  := $(shell uname -m)

# OpenSSL
# En Linux hay que verificar TANTO la librería (.so) COMO los headers de desarrollo.
# Sistemas con libssl3 pero sin libssl-dev tienen el .so pero no openssl/sha.h,
# lo que hace que -DCFV_WITH_OPENSSL rompa la compilación.
ifeq ($(UNAME),Darwin)
    OPENSSL_PREFIX := $(shell brew --prefix openssl 2>/dev/null || echo /usr/local)
    INCLUDES  += -I$(OPENSSL_PREFIX)/include
    LIBS      += -L$(OPENSSL_PREFIX)/lib -lssl -lcrypto
    CXXFLAGS  += -DCFV_WITH_OPENSSL
else
    OPENSSL_LIB := $(firstword $(wildcard \
        /usr/lib/$(ARCH)-linux-gnu/libcrypto.so.3 \
        /usr/lib/x86_64-linux-gnu/libcrypto.so.3 \
        /usr/lib/aarch64-linux-gnu/libcrypto.so.3 \
        /usr/lib/libcrypto.so))
    # Buscar headers en rutas estándar Y en la instalación de Node (fallback común)
    OPENSSL_HDR := $(firstword $(wildcard \
        /usr/include/openssl/sha.h \
        /usr/local/include/openssl/sha.h \
        /usr/include/node/openssl/sha.h))
    ifneq ($(OPENSSL_LIB),)
    ifneq ($(OPENSSL_HDR),)
        OPENSSL_INC := $(patsubst %/openssl/sha.h,%,$(OPENSSL_HDR))
        INCLUDES  += -I$(OPENSSL_INC)
        LIBS      += $(OPENSSL_LIB)
        CXXFLAGS  += -DCFV_WITH_OPENSSL
    endif
    endif
endif

# ── Targets ────────────────────────────────────────────────────────────────────

.PHONY: macos-cruzado macos-arm64-cruzado linux-arm64-check windows-cruzado cforge-nativo embebido semilla semilla-check cforge-desde-semilla autoalojado-check
.PHONY: all build debug release install uninstall test check stdlib-load-check \
	cli-check malformed-check sanitize-check backend-check install-check \
	bootstrap-bundle backend-core-bundle bootstrap-check backend-core-check ir-core-check object-lowering-check release-check clean help

# Regenera Stage 1 desde sus fuentes canónicas .cfv. Esto evita que el
# compilador empaquetado quede desfasado del lexer, parser o runtime reales.
bootstrap-bundle:
	@{ \
		echo '// C-Forge Stage 1 Bootstrap B4.'; \
		echo '// Archivo generado únicamente a partir de componentes escritos en .cfv.'; \
		for source in bootstrap/core_lexer.cfv bootstrap/core_ast.cfv \
			bootstrap/core_parser.cfv bootstrap/core_semantics.cfv \
			bootstrap/core_ownership.cfv \
			bootstrap/core_runtime.cfv bootstrap/core_emitter.cfv \
			bootstrap/core_driver.cfv; do \
			echo; echo "// ===== $$source ====="; cat "$$source"; \
		done; \
	} > bootstrap/stage1/cforge_stage1.cfv
	@echo "  GEN  bootstrap/stage1/cforge_stage1.cfv"

# Empaqueta los tres compiladores directos desde un único frontend y lowering.
# awk solo retira el CLI del emisor mínimo; la biblioteca binaria permanece .cfv.
backend-core-bundle:
	@set -e; \
	for platform in macho_arm64 elf_x64 pe_x64; do \
		output="bootstrap/direct/cforge_$${platform}_core.cfv"; \
		base="bootstrap/direct/cforge_$${platform}.cfv"; \
		backend="bootstrap/direct/cforge_$${platform}_core_backend.cfv"; \
		{ \
			for source in bootstrap/core_lexer.cfv bootstrap/core_ast.cfv \
				bootstrap/core_parser.cfv bootstrap/core_ir.cfv \
				bootstrap/core_object_lowering.cfv bootstrap/core_map_lowering.cfv \
				bootstrap/core_exception_lowering.cfv \
				bootstrap/core_ownership.cfv \
				bootstrap/core_modules.cfv; do cat "$$source"; echo; done; \
			awk '/^sea argumentos[^:]*: lista = argumentos_programa\(\)/ { exit } { print }' "$$base"; \
			cat "$$backend"; \
		} > "$$output"; \
		done
	@echo "  GEN  Mach-O ARM64, ELF x64 y PE x64 Core"

## Compilar (default)
all: build

## Compilar con O2
build: $(TARGET)

$(TARGET): $(SRC)
	@echo "  CXX  $< → $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $< $(LIBS)
	@echo "  OK   $@ compilado"

## Compilar en modo debug (sin optimización, con símbolos)
debug: CXXFLAGS := -std=c++20 -g -O0 -DDEBUG -Wall
debug: clean $(TARGET)
	@echo "  OK   debug build"

## Compilar con máxima optimización
release: CXXFLAGS := -std=c++20 -O3 -DNDEBUG -march=native
release: clean $(TARGET)
	@echo "  OK   release build"

## Compilar con soporte SDL2 (para stdlib/sdl.cfv y stdlib/gl.cfv)
sdl: CXXFLAGS += -DCFV_WITH_SDL2
sdl: LIBS     += -lSDL2 -lSDL2_ttf -lSDL2_mixer -lSDL2_image
sdl: $(TARGET)

## Instalar en el sistema
install: build
	@echo "  INSTALL  $(PREFIX)/bin/cforge"
	@install -d $(PREFIX)/bin
	@install -m 755 $(TARGET) $(PREFIX)/bin/cforge
	@ln -sf cforge $(PREFIX)/bin/cforgev
	@echo "  INSTALL  stdlib → $(PREFIX)/lib/cforge/stdlib/"
	@install -d $(PREFIX)/lib/cforge/stdlib
	@install -m 644 stdlib/*.cfv $(PREFIX)/lib/cforge/stdlib/
	@echo "  INSTALL  completions"
	@install -d $(PREFIX)/share/cforge/completions
	@install -m 644 completions/* $(PREFIX)/share/cforge/completions/ 2>/dev/null || true
	@echo ""
	@echo "  ✓ C-Forge instalado en $(PREFIX)"
	@echo "    Añade al PATH: export PATH=\"$(PREFIX)/bin:\$$PATH\""
	@echo "    Stdlib:        export CFORGE_STDLIB=\"$(PREFIX)/lib/cforge/stdlib\""

## Desinstalar
uninstall:
	@rm -f $(PREFIX)/bin/$(TARGET) $(PREFIX)/bin/cforge
	@rm -rf $(PREFIX)/lib/cforge
	@rm -rf $(PREFIX)/share/cforge
	@echo "  ✓ C-Forge desinstalado"

## Verificar todos los programas de prueba escritos en C-Forge
check: build
	@set -e; \
	for file in stdlib/*.cfv; do \
		echo "  CHECK $$file"; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) check "$$file"; \
	done; \
	for file in tests/cfv/*.cfv; do \
		echo "  CHECK $$file"; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) check "$$file"; \
	done; \
	for file in main.cfv ejemplos/*.cfv benchmarks/*.cfv \
		bootstrap/direct/cforge_macho_arm64.cfv \
		bootstrap/direct/cforge_elf_x64.cfv \
		bootstrap/direct/cforge_pe_x64.cfv; do \
		echo "  CHECK $$file"; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) check "$$file"; \
	done

## Ejecutar pruebas nativas .cfv
test: build
	@set -e; total=0; \
	for file in tests/cfv/*.cfv; do \
		echo "  TEST  $$file"; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) test "$$file"; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total archivos de prueba C-Forge aprobados"

## Importar y ejecutar realmente cada módulo publicado de la biblioteca.
## Esto detecta dependencias rotas que un análisis sintáctico aislado no ve.
stdlib-load-check: build
	@set -e; total=0; \
	for file in stdlib/*.cfv; do \
		module=$$(basename "$$file" .cfv); \
		if [ "$$module" = apple ]; then continue; fi; \
		fixture="/tmp/cforge-load-$$module.cfv"; \
		printf 'importar "%s"\n' "$$module" > "$$fixture"; \
		CFORGE_STDLIB=./stdlib ./$(TARGET) "$$fixture" >/dev/null; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total módulos C-Forge cargados realmente"

## Contrato público mínimo del CLI.
cli-check: build
	@set -e; \
	test "$$(./$(TARGET) --version)" = "C-Forge $(VERSION)"; \
	./$(TARGET) --help | grep -q "cforge check"; \
	./$(TARGET) check tests/cfv/01_nucleo.cfv >/dev/null; \
	if ./$(TARGET) check /tmp/no-existe-cforge.cfv >/tmp/cforge-cli-out 2>/tmp/cforge-cli-err; then \
		echo "  ERROR el CLI aceptó un archivo inexistente"; exit 1; \
	fi; \
	grep -q "C-Forge" /tmp/cforge-cli-err; \
	echo "  ✓ contrato CLI verificado"

## Entradas dañadas deben fallar limpiamente, nunca abortar ni generar traceback.
malformed-check: build
	@set -e; total=0; \
	for source in '}{' '@@@@' 'sea =' 'mostrar("sin cerrar)' 'si (verdadero) {'; do \
		printf '%s\n' "$$source" > /tmp/cforge-malformed.cfv; \
		if ./$(TARGET) /tmp/cforge-malformed.cfv >/tmp/cforge-malformed-out 2>/tmp/cforge-malformed-err; then \
			echo "  ERROR entrada inválida aceptada: $$source"; exit 1; \
		fi; \
		grep -q "C-Forge" /tmp/cforge-malformed-err; \
		if grep -Eqi 'traceback|segmentation fault|addresssanitizer|undefinedbehavior' \
			/tmp/cforge-malformed-out /tmp/cforge-malformed-err; then \
			echo "  ERROR fallo interno expuesto"; exit 1; \
		fi; \
		total=$$((total + 1)); \
	done; \
	echo "  ✓ $$total entradas dañadas rechazadas limpiamente"

## Ejecutar el núcleo con AddressSanitizer y UndefinedBehaviorSanitizer.
sanitize-check:
	@echo "  SANITIZE cforgev.cpp"
	@$(CXX) -std=c++20 -O1 -g -fno-omit-frame-pointer \
		-fsanitize=address,undefined $(INCLUDES) -o /tmp/cforge-sanitize \
		$(SRC) $(LIBS)
	@total=0; failed=0; \
	for file in tests/cfv/*.cfv; do \
		out=$$(ASAN_OPTIONS=detect_leaks=0 CFORGE_STDLIB=./stdlib \
			/tmp/cforge-sanitize test "$$file" 2>&1); \
		code=$$?; \
		if [ $$code -ne 0 ]; then \
			echo "  SANITIZE FAIL: $$file (exit $$code)"; \
			printf '%s\n' "$$out" | head -20; \
			failed=$$((failed + 1)); \
		fi; \
		total=$$((total + 1)); \
	done; \
	[ $$failed -eq 0 ] || { echo "  ✗ $$failed/$$total tests fallaron con sanitizadores"; exit 1; }; \
	echo "  ✓ $$total pruebas aprobadas con sanitizadores (ASan+UBSan, sin leak-detector)"

## Verificar emisores binarios directos y ejecutar el formato anfitrión
backend-check: build
	@set -e; fixture="$$(pwd)/bootstrap/fixtures/machine_hello_b6.cfv"; \
	./$(TARGET) bootstrap/direct/cforge_macho_arm64.cfv "$$fixture" -o /tmp/cforge-check-macho; \
	./$(TARGET) bootstrap/direct/cforge_elf_x64.cfv "$$fixture" -o /tmp/cforge-check-elf; \
	./$(TARGET) bootstrap/direct/cforge_pe_x64.cfv "$$fixture" -o /tmp/cforge-check.exe; \
	file /tmp/cforge-check-macho | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file /tmp/cforge-check-elf | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file /tmp/cforge-check.exe | grep -q "PE32+ executable.*x86-64"; \
	if [ "$(UNAME)" = "Darwin" ] && [ "$(ARCH)" = "arm64" ]; then \
		test "$$(/tmp/cforge-check-macho)" = "Hola maquina C-Forge"; \
	elif [ "$(UNAME)" = "Linux" ] && [ "$(ARCH)" = "x86_64" ]; then \
		test "$$(/tmp/cforge-check-elf)" = "Hola maquina C-Forge"; \
	fi; \
	echo "  ✓ Mach-O ARM64, ELF x64 y PE x64 verificados"

## Probar una instalación aislada sin modificar el sistema
install-check: build
	@set -e; prefix=/tmp/cforge-install-check; \
	rm -rf "$$prefix"; \
	$(MAKE) install PREFIX="$$prefix" >/dev/null; \
	test "$$($$prefix/bin/cforge --version)" = "C-Forge $(VERSION)"; \
	CFORGE_STDLIB="$$prefix/lib/cforge/stdlib" \
		"$$prefix/bin/cforge" tests/cfv/01_nucleo.cfv >/dev/null; \
	echo "  ✓ instalación aislada verificada en $$prefix"

## Verificar el frontend autoalojado de C-Forge Core.
## Stage 0 construye Stage 1; Stage 1 construye Stage 2; Stage 2 construye
## Stage 3. Los dos últimos artefactos deben ser idénticos byte por byte.
bootstrap-check: bootstrap-bundle
	@set -e; dir=$$(mktemp -d /tmp/cforge-bootstrap.XXXXXX); \
	$(CXX) -std=c++20 -O2 -Wall -Wextra -Wpedantic \
		bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	"$$dir/stage0" bootstrap/stage1/cforge_stage1.cfv -o "$$dir/stage1" >/dev/null; \
	"$$dir/stage1" bootstrap/stage1/cforge_stage1.cfv -o "$$dir/stage2" >/dev/null; \
	"$$dir/stage2" bootstrap/stage1/cforge_stage1.cfv -o "$$dir/stage3" >/dev/null; \
	cmp "$$dir/stage2" "$$dir/stage3"; \
	"$$dir/stage3" bootstrap/fixtures/minimal.cfv -o "$$dir/minimal" >/dev/null; \
	test "$$($$dir/minimal)" = "$$(printf 'C-Forge Core Bootstrap\n42')"; \
	"$$dir/stage3" bootstrap/fixtures/mapas_core.cfv -o "$$dir/mapas" >/dev/null; \
	test "$$($$dir/mapas)" = "$$(printf '8\n12\n443')"; \
	"$$dir/stage3" bootstrap/fixtures/excepciones_core.cfv -o "$$dir/excepciones" >/dev/null; \
	test "$$($$dir/excepciones)" = "capturado: saldo insuficiente"; \
	echo "  ✓ Stage 2 y Stage 3 son idénticos; compilador Core autoalojado"

## Backend nativo x86-64 / ELF sin libc + runtime propio (runtime/*.cfv).
## Compila cada prueba de tests/nativo a un ELF estático, verifica que no
## enlace nada dinámico, la ejecuta y compara su salida. El lexer nativo debe
## producir exactamente los mismos tokens que el lexer Core.
RUNTIME_NATIVO := runtime/sys_linux.cfv runtime/mem.cfv runtime/str.cfv \
	runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
nativo-check:
	@set -e; dir=$$(mktemp -d /tmp/cforge-nativo.XXXXXX); \
	$(CXX) -std=c++20 -O2 bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	cat bootstrap/core_lexer.cfv bootstrap/core_ast.cfv bootstrap/core_parser.cfv \
		bootstrap/nativo/x64_nativo.cfv bootstrap/nativo/driver_nativo.cfv > "$$dir/nativo.cfv"; \
	"$$dir/stage0" "$$dir/nativo.cfv" -o "$$dir/nativo" >/dev/null; \
	for prueba in 01_memoria 02_textos 03_listas 04_prueba_de_fuego 05_lexer; do \
		extra=""; [ "$$prueba" = 05_lexer ] && extra=bootstrap/nativo/lexer.cfv; \
		env PATH=/nonexistent "$$dir/nativo" -o "$$dir/$$prueba" $(RUNTIME_NATIVO) $$extra tests/nativo/$$prueba.cfv >/dev/null; \
		if ldd "$$dir/$$prueba" >/dev/null 2>&1; then echo "  ✗ $$prueba enlaza librerías dinámicas"; exit 1; fi; \
	done; \
	for prueba in 01_memoria 02_textos 03_listas; do \
		"$$dir/$$prueba" > "$$dir/$$prueba.real"; \
		diff -u tests/nativo/$$prueba.salida "$$dir/$$prueba.real"; \
	done; \
	"$$dir/04_prueba_de_fuego" tests/nativo/fixtures/entrada.cfv "$$dir/reporte" > "$$dir/04.real"; \
	diff -u tests/nativo/04_prueba_de_fuego.salida "$$dir/04.real"; \
	diff -u tests/nativo/fixtures/reporte.esperado "$$dir/reporte"; \
	cat bootstrap/core_lexer.cfv bootstrap/nativo/referencia_lexer.cfv > "$$dir/ref.cfv"; \
	"$$dir/stage0" "$$dir/ref.cfv" -o "$$dir/ref" >/dev/null; \
	for fuente in bootstrap/core_parser.cfv bootstrap/nativo/x64_nativo.cfv $(RUNTIME_NATIVO); do \
		"$$dir/05_lexer" "$$fuente" "$$dir/lex.nativo" >/dev/null; \
		"$$dir/ref" "$$fuente" "$$dir/lex.ref"; \
		cmp -s "$$dir/lex.nativo" "$$dir/lex.ref" || { echo "  ✗ el lexer nativo difiere en $$fuente"; exit 1; }; \
	done; \
	echo "  ✓ Backend nativo ELF sin libc: memoria, textos, listas, archivos, f64 y lexer autoalojado"

## ── C-Forge 100 % C-Forge (Linux x86-64) ─────────────────────────────────
## cforge_self.cfv es el compilador (escrito en C-Forge); cforge_cli.cfv es
## el comando cforge oficial, con el runtime incrustado (embebido.cfv).
##   Stage 0  C++ (solo arranque)  → x64_nativo
##   Stage 1  x64_nativo           → compilador mínimo (principal_bootstrap)
##   Stage 2  Stage 1              → cforge oficial
##   Stage 3  Stage 2              → cforge oficial  (Stage 2 = Stage 3)
## La semilla bootstrap/semilla/cforge-linux-x64 (= Stage 3) permite
## reconstruir sin C++: semilla → cforge (idéntico byte por byte).
RUNTIME_LENGUAJE := $(RUNTIME_NATIVO) runtime/sys_linux_ext.cfv runtime/map.cfv --puente runtime/dyn.cfv runtime/biblioteca.cfv --lenguaje runtime/lenguaje.cfv
PRUEBAS_LENGUAJE_NATIVAS := $(basename $(notdir $(wildcard tests/cfv/*.cfv)))
FUENTES_COMPILADOR := $(RUNTIME_NATIVO) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/biblioteca_c.cfv
FUENTES_CFORGE := $(FUENTES_COMPILADOR) bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
EMBEBIDO_ARGS := --nativo $(RUNTIME_NATIVO) runtime/sys_linux_ext.cfv runtime/sys_linux_arm64.cfv runtime/sys_linux_arm64_ext.cfv runtime/sys_windows.cfv runtime/sys_windows_ext.cfv runtime/sys_macos.cfv runtime/sys_macos_ext.cfv runtime/map.cfv --puente runtime/dyn.cfv runtime/biblioteca.cfv --lenguaje runtime/lenguaje.cfv --opcional runtime/sdl.cfv
SEMILLA := bootstrap/semilla/cforge-linux-x64

## Construye ./cforge-nativo desde C++ (Stage 0) y verifica Stage 2 = Stage 3.
cforge-nativo:
	@set -e; dir=$$(mktemp -d /tmp/cforge-nativo.XXXXXX); \
	$(CXX) -std=c++20 -O2 bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	cat bootstrap/core_lexer.cfv bootstrap/core_ast.cfv bootstrap/core_parser.cfv \
		bootstrap/nativo/x64_nativo.cfv bootstrap/nativo/driver_nativo.cfv > "$$dir/nativo.cfv"; \
	"$$dir/stage0" "$$dir/nativo.cfv" -o "$$dir/nativo" >/dev/null; \
	"$$dir/nativo" -o "$$dir/stage1" $(FUENTES_COMPILADOR) bootstrap/nativo/principal_bootstrap.cfv >/dev/null; \
	env -i "$$dir/stage1" -o "$$dir/embeber" $(RUNTIME_NATIVO) bootstrap/nativo/embeber.cfv >/dev/null; \
	"$$dir/embeber" "$$dir/embebido.cfv" $(VERSION) $(EMBEBIDO_ARGS) >/dev/null; \
	if ! cmp -s "$$dir/embebido.cfv" bootstrap/nativo/embebido.cfv; then \
		echo "  ✗ bootstrap/nativo/embebido.cfv está desactualizado: ejecuta make embebido"; exit 1; fi; \
	env -i "$$dir/stage1" -o "$$dir/stage2" $(FUENTES_CFORGE) >/dev/null; \
	env -i "$$dir/stage2" -o "$$dir/stage3" $(FUENTES_CFORGE) >/dev/null; \
	cmp "$$dir/stage2" "$$dir/stage3"; \
	if ldd "$$dir/stage3" >/dev/null 2>&1; then echo "  ✗ cforge enlaza librerías dinámicas"; exit 1; fi; \
	cp "$$dir/stage3" cforge-nativo; \
	sha256sum "$$dir/stage2" "$$dir/stage3" | sed "s#$$dir/##"; \
	echo "  ✓ cforge-nativo: Stage 2 = Stage 3, $$(wc -c < cforge-nativo) bytes, sin libc ni C++"

## ── Windows x86-64 (PE64), compilado de forma cruzada desde Linux ───────
RUNTIME_WINDOWS := runtime/sys_windows.cfv runtime/mem.cfv runtime/str.cfv runtime/vec.cfv runtime/io.cfv runtime/f64.cfv
FUENTES_CFORGE_WINDOWS := $(RUNTIME_WINDOWS) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/biblioteca_c.cfv bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
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
FUENTES_CFORGE_MACOS := $(RUNTIME_MACOS) bootstrap/nativo/lexer.cfv bootstrap/nativo/cforge_self.cfv bootstrap/nativo/gen.cfv bootstrap/nativo/gen_x64.cfv bootstrap/nativo/gen_a64.cfv bootstrap/nativo/biblioteca_c.cfv bootstrap/nativo/embebido.cfv bootstrap/nativo/paquetes.cfv bootstrap/nativo/formato.cfv bootstrap/nativo/lsp.cfv bootstrap/nativo/xcode.cfv bootstrap/nativo/cforge_cli.cfv
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

## Regenera el runtime incrustado (tras cambiar runtime/*.cfv o VERSION).
embebido:
	@set -e; dir=$$(mktemp -d /tmp/cforge-emb.XXXXXX); \
	$(CXX) -std=c++20 -O2 bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	cat bootstrap/core_lexer.cfv bootstrap/core_ast.cfv bootstrap/core_parser.cfv \
		bootstrap/nativo/x64_nativo.cfv bootstrap/nativo/driver_nativo.cfv > "$$dir/nativo.cfv"; \
	"$$dir/stage0" "$$dir/nativo.cfv" -o "$$dir/nativo" >/dev/null; \
	"$$dir/nativo" -o "$$dir/embeber" $(RUNTIME_NATIVO) bootstrap/nativo/embeber.cfv >/dev/null; \
	"$$dir/embeber" bootstrap/nativo/embebido.cfv $(VERSION) $(EMBEBIDO_ARGS)

## Actualiza la semilla con el cforge actual (tras cambiar el compilador).
semilla: cforge-nativo
	@mkdir -p bootstrap/semilla
	@cp cforge-nativo $(SEMILLA)
	@sha256sum $(SEMILLA) | sed 's#bootstrap/semilla/##' > $(SEMILLA).sha256
	@echo "  ✓ semilla actualizada: $$(cat $(SEMILLA).sha256)"

## cforge desde la semilla, sin C++ (lo usa install.sh desde el código fuente).
cforge-desde-semilla:
	@cp $(SEMILLA) ./.semilla && chmod +x ./.semilla
	@./.semilla -o cforge $(FUENTES_CFORGE) >/dev/null && rm -f ./.semilla
	@echo "  ✓ cforge compilado por la semilla: $$(./cforge --version)"

## Reconstruye cforge desde la semilla, sin C++, y comprueba que el resultado
## es idéntico a la semilla y al cforge construido desde C++.
semilla-check: cforge-nativo
	@set -e; dir=$$(mktemp -d /tmp/cforge-semilla.XXXXXX); \
	(cd bootstrap/semilla && sha256sum -c cforge-linux-x64.sha256 >/dev/null); \
	cp $(SEMILLA) "$$dir/semilla"; chmod +x "$$dir/semilla"; \
	env -i PATH=/nonexistent "$$dir/semilla" -o "$$dir/s1" $(FUENTES_CFORGE) >/dev/null; \
	env -i PATH=/nonexistent "$$dir/s1" -o "$$dir/s2" $(FUENTES_CFORGE) >/dev/null; \
	cmp "$$dir/s1" "$$dir/s2"; \
	if ! cmp -s "$$dir/s1" $(SEMILLA); then echo "  ✗ la semilla está desactualizada: ejecuta make semilla"; exit 1; fi; \
	cmp "$$dir/s1" cforge-nativo; \
	echo "  ✓ semilla → cforge sin C++: idéntico a la semilla y al arranque desde C++"

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

## Verificar los backends Core B6.8 sin toolchain durante la emisión.
backend-core-check: backend-core-bundle
	@set -e; dir=$$(mktemp -d /tmp/cforge-backend-core.XXXXXX); \
	$(CXX) -std=c++20 -O2 -Wall -Wextra -Wpedantic \
		bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	"$$dir/stage0" bootstrap/direct/cforge_macho_arm64_core.cfv \
		-o "$$dir/macho-core" >/dev/null; \
	"$$dir/stage0" bootstrap/direct/cforge_pe_x64_core.cfv \
		-o "$$dir/pe-core" >/dev/null; \
	"$$dir/stage0" bootstrap/direct/cforge_elf_x64_core.cfv \
		-o "$$dir/elf-core" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/uno-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/dos-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/uno.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/dos.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/uno-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_runtime_b6.cfv -o "$$dir/dos-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_objects_b611.cfv -o "$$dir/objetos-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_objects_b611.cfv -o "$$dir/objetos.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_objects_b611.cfv -o "$$dir/objetos-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_methods_b612.cfv -o "$$dir/metodos-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_methods_b612.cfv -o "$$dir/metodos.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_methods_b612.cfv -o "$$dir/metodos-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_mutable_methods_b613.cfv -o "$$dir/mutables-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_mutable_methods_b613.cfv -o "$$dir/mutables.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_mutable_methods_b613.cfv -o "$$dir/mutables-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_lifecycle_b614.cfv -o "$$dir/ciclo-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_lifecycle_b614.cfv -o "$$dir/ciclo.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_lifecycle_b614.cfv -o "$$dir/ciclo-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_interfaces_b615.cfv -o "$$dir/interfaz-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_interfaces_b615.cfv -o "$$dir/interfaz.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_interfaces_b615.cfv -o "$$dir/interfaz-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/modules_b616/main.cfv -o "$$dir/modulos-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/modules_b616/main.cfv -o "$$dir/modulos.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/modules_b616/main.cfv -o "$$dir/modulos-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_maps_b617.cfv -o "$$dir/mapas-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_maps_b617.cfv -o "$$dir/mapas.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_maps_b617.cfv -o "$$dir/mapas-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_exceptions_b619.cfv -o "$$dir/excepciones-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_exceptions_b619.cfv -o "$$dir/excepciones.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_exceptions_b619.cfv -o "$$dir/excepciones-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_exception_calls_b620.cfv -o "$$dir/excepciones-funcion-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_exception_calls_b620.cfv -o "$$dir/excepciones-funcion.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_exception_calls_b620.cfv -o "$$dir/excepciones-funcion-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_ownership_b621.cfv -o "$$dir/ownership-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_ownership_b621.cfv -o "$$dir/ownership.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_ownership_b621.cfv -o "$$dir/ownership-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_nested_lifecycle_b621.cfv -o "$$dir/ambitos-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_nested_lifecycle_b621.cfv -o "$$dir/ambitos.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_nested_lifecycle_b621.cfv -o "$$dir/ambitos-elf" >/dev/null; \
	env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_exception_cleanup_b621.cfv -o "$$dir/limpieza-error-macho" >/dev/null; \
	env PATH=/nonexistent "$$dir/pe-core" \
		bootstrap/fixtures/machine_exception_cleanup_b621.cfv -o "$$dir/limpieza-error.exe" >/dev/null; \
	env PATH=/nonexistent "$$dir/elf-core" \
		bootstrap/fixtures/machine_exception_cleanup_b621.cfv -o "$$dir/limpieza-error-elf" >/dev/null; \
	for invalido in \
		bootstrap/fixtures/machine_ownership_use_after_move_b621.cfv \
		bootstrap/fixtures/machine_ownership_move_borrowed_b621.cfv \
		bootstrap/fixtures/machine_ownership_alias_b621.cfv; do \
		if env PATH=/nonexistent "$$dir/macho-core" "$$invalido" \
			-o "$$dir/ownership-invalido" >/dev/null 2>&1; then \
			echo "ownership inválido aceptado: $$invalido" >&2; exit 1; \
		fi; \
	done; \
	if env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/machine_interfaces_invalid_b615.cfv \
		-o "$$dir/interfaz-invalida" >/dev/null 2>&1; then \
		echo "la interfaz incompleta fue aceptada" >&2; exit 1; \
	fi; \
	if env PATH=/nonexistent "$$dir/macho-core" \
		bootstrap/fixtures/modules_b616/ciclo_a.cfv \
		-o "$$dir/ciclo-importacion" >/dev/null 2>&1; then \
		echo "el ciclo de importación fue aceptado" >&2; exit 1; \
	fi; \
	cmp "$$dir/uno-macho" "$$dir/dos-macho"; \
	cmp "$$dir/uno.exe" "$$dir/dos.exe"; \
	cmp "$$dir/uno-elf" "$$dir/dos-elf"; \
	file "$$dir/uno-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/uno.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/uno-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/objetos-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/objetos.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/objetos-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/metodos-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/metodos.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/metodos-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/mutables-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/mutables.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/mutables-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/ciclo-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/ciclo.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/ciclo-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/interfaz-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/interfaz.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/interfaz-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/modulos-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/modulos.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/modulos-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/mapas-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/mapas.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/mapas-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/excepciones-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/excepciones.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/excepciones-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/excepciones-funcion-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/excepciones-funcion.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/excepciones-funcion-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/ownership-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/ownership.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/ownership-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/ambitos-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/ambitos.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/ambitos-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	file "$$dir/limpieza-error-macho" | grep -qE "Mach-O 64-bit (executable )?arm64( executable)?"; \
	file "$$dir/limpieza-error.exe" | grep -q "PE32+ executable.*x86-64"; \
	file "$$dir/limpieza-error-elf" | grep -q "ELF 64-bit LSB executable, x86-64"; \
	if [ "$(UNAME)" = "Darwin" ] && [ "$(ARCH)" = "arm64" ]; then \
		test "$$($$dir/uno-macho)" = "C-FORGE-B6.7-OK"; \
		test "$$($$dir/objetos-macho)" = "C-FORGE-B6.11-OBJECT-OK"; \
		test "$$($$dir/metodos-macho)" = "C-FORGE-B6.12-METHOD-OK"; \
		test "$$($$dir/mutables-macho)" = "C-FORGE-B6.13-MUTABLE-OK"; \
		test "$$($$dir/ciclo-macho)" = "$$(printf 'C-FORGE-B6.14-CONSTRUCTOR-OK\nC-FORGE-B6.14-DESTRUCTOR-OK')"; \
		test "$$($$dir/interfaz-macho)" = "C-FORGE-B6.15-INTERFACE-OK"; \
		test "$$($$dir/modulos-macho)" = "C-FORGE-B6.16-MODULES-OK"; \
		test "$$($$dir/mapas-macho)" = "C-FORGE-B6.17-MAPS-OK"; \
		test "$$($$dir/excepciones-macho)" = "$$(printf 'saldo insuficiente\ncaptura completada')"; \
		test "$$($$dir/excepciones-funcion-macho)" = "$$(printf 'saldo insuficiente desde funcion\npropagacion capturada')"; \
		test "$$($$dir/ownership-macho)" = "C-FORGE-B6.21-OWNERSHIP-OK"; \
		test "$$($$dir/ambitos-macho)" = "$$(printf 'dentro\ndestruir interior\nfuera\ndestruir exterior')"; \
		test "$$($$dir/limpieza-error-macho)" = "$$(printf 'limpieza antes del error\nerror controlado')"; \
	fi; \
	if [ "$(UNAME)" = "Linux" ] && [ "$(ARCH)" = "x86_64" ]; then \
		test "$$($$dir/uno-elf)" = "C-FORGE-B6.7-OK"; \
		test "$$($$dir/objetos-elf)" = "C-FORGE-B6.11-OBJECT-OK"; \
		test "$$($$dir/metodos-elf)" = "C-FORGE-B6.12-METHOD-OK"; \
		test "$$($$dir/mutables-elf)" = "C-FORGE-B6.13-MUTABLE-OK"; \
		test "$$($$dir/ciclo-elf)" = "$$(printf 'C-FORGE-B6.14-CONSTRUCTOR-OK\nC-FORGE-B6.14-DESTRUCTOR-OK')"; \
		test "$$($$dir/interfaz-elf)" = "C-FORGE-B6.15-INTERFACE-OK"; \
		test "$$($$dir/modulos-elf)" = "C-FORGE-B6.16-MODULES-OK"; \
		test "$$($$dir/mapas-elf)" = "C-FORGE-B6.17-MAPS-OK"; \
		test "$$($$dir/excepciones-elf)" = "$$(printf 'saldo insuficiente\ncaptura completada')"; \
		test "$$($$dir/excepciones-funcion-elf)" = "$$(printf 'saldo insuficiente desde funcion\npropagacion capturada')"; \
		test "$$($$dir/ownership-elf)" = "C-FORGE-B6.21-OWNERSHIP-OK"; \
		test "$$($$dir/ambitos-elf)" = "$$(printf 'dentro\ndestruir interior\nfuera\ndestruir exterior')"; \
		test "$$($$dir/limpieza-error-elf)" = "$$(printf 'limpieza antes del error\nerror controlado')"; \
	fi; \
	echo "  ✓ Mach-O ARM64, ELF x64 y PE x64 Core B6.21 con ownership y RAII"

## Verificar el IR común de objetos que consumirán los tres backends.
ir-core-check:
	@set -e; dir=$$(mktemp -d /tmp/cforge-ir-core.XXXXXX); \
	awk 'FNR==1 { print "" } { print }' \
		bootstrap/core_ast.cfv \
		bootstrap/core_ir.cfv \
		bootstrap/fixtures/ir_b69_driver.cfv > "$$dir/ir.cfv"; \
	$(CXX) -std=c++20 -O2 -Wall -Wextra -Wpedantic \
		bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	"$$dir/stage0" "$$dir/ir.cfv" -o "$$dir/ir-test" >/dev/null; \
	test "$$($$dir/ir-test)" = \
		'CFIR1[estructura Punto size=16 align=8 {x:numero@0,y:numero@8};clase Contador size=8 align=8 {valor:numero@0}]'; \
	echo "  ✓ C-Forge Core IR 1 determinista verificado"

## Verificar la reducción común de objetos antes de emitir Mach-O, ELF o PE.
object-lowering-check:
	@set -e; dir=$$(mktemp -d /tmp/cforge-object-lowering.XXXXXX); \
	awk 'FNR==1 { print "" } { print }' \
		bootstrap/core_ast.cfv \
		bootstrap/core_ir.cfv \
		bootstrap/core_object_lowering.cfv \
		bootstrap/fixtures/object_lowering_b610.cfv > "$$dir/lowering.cfv"; \
	$(CXX) -std=c++20 -O2 -Wall -Wextra -Wpedantic \
		bootstrap/stage0/cforge_bootstrap.cpp -o "$$dir/stage0"; \
	"$$dir/stage0" "$$dir/lowering.cfv" -o "$$dir/lowering-test" >/dev/null; \
	"$$dir/lowering-test" > "$$dir/ast.txt"; \
	grep -q 'p__campo__x' "$$dir/ast.txt"; \
	grep -q 'p__campo__y' "$$dir/ast.txt"; \
	! grep -q 'Estructura' "$$dir/ast.txt"; \
	echo "  ✓ objetos Core reducidos a almacenamiento común verificable"

## Smoke test de instalación (simula usuario nuevo)
smoke-test: build
	@echo "  SMOKE  tests/install-smoke/run_smoke.sh"
	@CFORGE_STDLIB=$(PWD)/stdlib bash tests/install-smoke/run_smoke.sh $(PWD)/$(TARGET)

## Gate único exigido antes de publicar una versión estable.
release-check: clean build check test stdlib-load-check cli-check malformed-check \
	backend-check install-check bootstrap-check backend-core-check ir-core-check \
	object-lowering-check sanitize-check smoke-test
	@echo ""
	@echo "  ✓ GATE DE ESTABILIDAD C-FORGE COMPLETO"

## Benchmark rápido
bench: build
	@echo "  BENCH  fib(30)"
	@echo 'funcion fib(n) { si(n<=1){retornar n} retornar fib(n-1)+fib(n-2) } mostrar(fib(30))' \
	    > /tmp/bench.cfv
	@time ./$(TARGET) /tmp/bench.cfv

## Limpiar artefactos de compilación
clean:
	@rm -f cforge cforgev *.o
	@echo "  CLEAN  artefactos eliminados"

## Ayuda
help:
	@echo ""
	@echo "  C-Forge Makefile"
	@echo "  ──────────────────────────────────────────"
	@echo "  make              Compilar cforge"
	@echo "  make debug        Compilar en modo debug"
	@echo "  make release      Compilar con O3 + march=native"
	@echo "  make sdl          Compilar con soporte SDL2"
	@echo "  make install      Instalar en $(PREFIX)"
	@echo "  make object-lowering-check Verificar reducción común de objetos B6.10"
	@echo "  make uninstall    Desinstalar"
	@echo "  make check        Verificar sintaxis de pruebas .cfv"
	@echo "  make test         Ejecutar tests básicos"
	@echo "  make stdlib-load-check Cargar realmente cada módulo"
	@echo "  make cli-check    Verificar contrato del CLI"
	@echo "  make malformed-check Rechazar entradas dañadas"
	@echo "  make sanitize-check Ejecutar ASan y UBSan"
	@echo "  make backend-check Verificar Mach-O, ELF y PE"
	@echo "  make install-check Probar instalación aislada"
	@echo "  make bootstrap-check Verificar autoalojamiento Stage 1→2→3"
	@echo "  make backend-core-check Verificar backends Core B6.8 sin toolchain"
	@echo "  make ir-core-check Verificar el IR común de objetos B6.9"
	@echo "  make release-check Ejecutar todos los gates de estabilidad"
	@echo "  make bench        Benchmark fib(30)"
	@echo "  make clean        Limpiar artefactos"
	@echo ""
	@echo "  Variables:"
	@echo "  CXX=clang++       Cambiar compilador"
	@echo "  PREFIX=/opt/cf    Cambiar directorio de instalación"
	@echo ""
