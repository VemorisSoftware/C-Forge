#!/bin/sh
# tests/paquetes/prueba.sh COMPILADOR — gestor de paquetes de punta a punta
# con repositorios git locales (CFORGE_GIT_BASE=file://...): init, add con
# dependencia transitiva, cforge.lock, importar "alias" y "alias/modulo",
# run/build/check sin archivo desde un subdirectorio, --como, @ref y remove.
set -e
C=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
R=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d)
nativa() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else echo "$1"; fi; }
git_c() { git -c user.name=cforge -c user.email=ci@c-forge.org -c init.defaultBranch=main "$@"; }

mkdir -p "$T/repos/vemoris/saludos" "$T/repos/vemoris/textos"
cd "$T/repos/vemoris/textos"
printf 'funcion gritar(s) { retornar texto_mayusculas(s) + "!" }\n' > textos.cfv
git_c init -q && git_c add -A && git_c commit -qm v1
cd "$T/repos/vemoris/saludos"
printf '[paquete]\nnombre = "saludos"\nprincipal = "saludos.cfv"\n\n[dependencias]\ntextos = "vemoris/textos"\n' > cforge.toml
printf 'importar "textos"\nfuncion saludar(n) { retornar gritar("hola " + n) }\n' > saludos.cfv
printf 'funcion despedir(n) { retornar "chao " + n }\n' > extra.cfv
git_c init -q && git_c add -A && git_c commit -qm v1

export CFORGE_GIT_BASE="file:///$(nativa "$T/repos" | sed 's#^/##')/"
export CFORGE_HOME="$(nativa "$T/home")"
export CFORGE_STDLIB="$(nativa "$R/stdlib")"
cd "$T"
"$C" init app >/dev/null
cd app
"$C" add vemoris/saludos >/dev/null
grep -q '^saludos = "vemoris/saludos"' cforge.toml
grep -Eq '^textos = "vemoris/textos#[0-9a-f]{40}"' cforge.lock
printf 'importar "saludos"\nimportar "saludos/extra"\nmostrar(saludar("mundo"))\nmostrar(despedir("mundo"))\n' > principal.cfv
esperado=$(printf 'HOLA MUNDO!\nchao mundo')
[ "$("$C" run | tr -d '\r')" = "$esperado" ]
mkdir -p sub && cd sub
"$C" build -o "$T/app_bin" >/dev/null
[ "$("$T/app_bin" | tr -d '\r')" = "$esperado" ]
"$C" check >/dev/null
cd ..
"$C" add vemoris/textos@main --como txt >/dev/null
grep -q '^txt = "vemoris/textos@main"' cforge.toml
"$C" remove saludos >/dev/null
! grep -q '^saludos' cforge.toml
grep -q '^txt' cforge.lock
rm -rf "$T"
echo "  ✓ paquetes: init, add (transitivo), lock, importar alias/modulo, run/build/check, --como, @ref, remove"
