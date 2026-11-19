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
rm -rf "$T"
echo "  ✓ herramientas: cforge test --coverage (también si falla) y cforge doc (Markdown y HTML)"
