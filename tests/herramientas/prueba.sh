#!/bin/sh
# tests/herramientas/prueba.sh COMPILADOR — cforge test --coverage y cforge doc.
set -e
C=$1
D=$(dirname "$0")
T=$(mktemp -d)
salida=$(CFORGE_STDLIB=stdlib "$C" test "$D/cubierto.cfv" --coverage | tr -d '\r')
echo "$salida" | grep -q '^\[OK\]'
echo "$salida" | grep -q 'cubierto.cfv: 7/10 líneas (70.0 %)'
echo "$salida" | grep -q 'sin ejecutar: 7, 11, 13'
# Una prueba que falla también informa la cobertura (y conserva el código).
printf 'afirmar(1 == 2, "adrede")\nmostrar("no")\n' > "$T/falla.cfv"
if CFORGE_STDLIB=stdlib "$C" test "$T/falla.cfv" --coverage > "$T/f.txt" 2>&1; then exit 1; fi
grep -q '1/2 líneas' "$T/f.txt"
"$C" doc "$D/cubierto.cfv" > "$T/doc.md"
grep -q '^## `funcion signo(x)`' "$T/doc.md"
grep -q '^Signo de x como texto.' "$T/doc.md"
grep -q '^## `async funcion doble(x)`' "$T/doc.md"
! grep -q '_privada' "$T/doc.md"
"$C" doc stdlib -o "$T/doc.html" >/dev/null
grep -q '<h2><code>funcion db_abrir(ruta)</code></h2>' "$T/doc.html"
# cforge bindgen: cabecera con macros, extern "C", enum, typedef, include
# local, variádica, float e inline.
CFORGE_STDLIB=stdlib "$C" bindgen "$D/ejemplo.h" --lib c -o "$T/ej.cfv" | grep -q '6 funciones, 7 constantes; 2 omitidas'
grep -q 'extern "c" funcion strlen(s_: texto): largo' "$T/ej.cfv"
grep -q 'extern "c" funcion ej_media(v_: puntero, n_: largo): numero' "$T/ej.cfv"
grep -q 'extern "c" funcion ej_registrar(ctx_: puntero, cb_: puntero, dato_: puntero): entero' "$T/ej.cfv"
grep -q '^sea EJ_AZUL = 6' "$T/ej.cfv"
grep -q '^sea EJ_DESPLAZADO = 16' "$T/ej.cfv"
grep -q 'ej_imprimir: argumentos variables' "$T/ej.cfv"
! grep -q 'ej_doble' "$T/ej.cfv"
if [ "$(uname -s)" = Linux ]; then
    printf 'importar "ej"\nmostrar(strlen("hola mundo"))\nmostrar(abs(0 - 42))\n' > "$T/uso.cfv"
    [ "$(cd "$T" && CFORGE_STDLIB="$OLDPWD/stdlib" "$OLDPWD/$C" uso.cfv | tr '\n' ' ')" = "10 42 " ]
fi
rm -rf "$T"
echo "  ✓ herramientas: cforge test --coverage (también si falla) y cforge doc (Markdown y HTML) y cforge bindgen"
