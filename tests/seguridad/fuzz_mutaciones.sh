#!/bin/sh
# tests/seguridad/fuzz_mutaciones.sh COMPILADOR [CASOS]
# Toma programas reales (tests/cfv y ejemplos), les aplica mutaciones
# (borrar o duplicar líneas, insertar tokens, anidar, números enormes) y
# exige que el compilador nunca se cierre por una señal ni se cuelgue.
set -u
C=${1:-./cforge}
N=${2:-300}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
ls tests/cfv/*.cfv ejemplos/*.cfv > "$T/fuentes"
total=$(wc -l < "$T/fuentes")
fallas=0
i=1
while [ "$i" -le "$N" ]; do
    linea=$(( (i * 7919 + ${FUZZ_SEMILLA:-0}) % total + 1 ))
    src=$(sed -n "${linea}p" "$T/fuentes")
    awk -v semilla="$((i + ${FUZZ_SEMILLA:-0}))" -f tests/seguridad/mutar.awk "$src" > "$T/a.cfv"
    awk -v semilla=$((i + 100000 + ${FUZZ_SEMILLA:-0})) -f tests/seguridad/mutar.awk "$T/a.cfv" > "$T/caso.cfv"
    codigo=0
    CFORGE_STDLIB=stdlib timeout 20 "$C" check "$T/caso.cfv" > /dev/null 2>&1 || codigo=$?
    if [ "$codigo" -ge 124 ]; then
        echo "  ✗ caso $i ($src): el compilador terminó con $codigo"
        cp "$T/caso.cfv" "/tmp/cforge-fuzz-$i.cfv"
        fallas=$((fallas + 1))
    fi
    i=$((i + 1))
done
[ "$fallas" -eq 0 ] || exit 1
echo "  ✓ fuzz por mutaciones: $N programas mutados, sin cierres ni cuelgues"
