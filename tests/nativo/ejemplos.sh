#!/bin/sh
# Verifica ejemplos/*.cfv con el cforge nativo (sin el intérprete C++):
#   - programas normales: salida estándar y código de salida contra
#     ejemplos/salidas/<nombre>.salida y .codigo;
#   - app_produccion: servidor HTTP real, consultado con curl;
#   - trafico_visual: ciclo de SDL que sigue corriendo (requiere libSDL2).
# Uso: tests/nativo/ejemplos.sh [ruta/a/cforge]
C=${1:-./cforge-nativo}
C=$(cd "$(dirname "$C")" && pwd)/$(basename "$C")
cd "$(dirname "$0")/../.." || exit 1
export CFORGE_STDLIB="$PWD/stdlib"
tmp=$(mktemp -d /tmp/cforge-ejemplos.XXXXXX)
ok=0; total=0; fallas=""
falla() { fallas="$fallas $1"; echo "  ✗ $1: $2"; }
# Portabilidad Linux / Windows (Git Bash).
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; *) WINDOWS=0 ;; esac
hay_sdl() {
  if [ $WINDOWS = 1 ]; then [ -f "$(dirname "$C")/SDL2.dll" ]; return; fi
  ldconfig -p 2>/dev/null | grep -q libSDL2-2.0
}
puerto_escuchando() {
  if [ -r /proc/net/tcp ]; then grep -q ":0FA0 00000000:0000 0A" /proc/net/tcp; else netstat -an 2>/dev/null | grep -q ":4000 .*LISTEN"; fi
}
detener_programas() {
  if [ $WINDOWS = 1 ]; then taskkill //F //FI "IMAGENAME eq cforge-run-*" >/dev/null 2>&1; else pkill -f cforge-run- >/dev/null 2>&1; fi
}
for f in ejemplos/*.cfv; do
  b=$(basename "$f" .cfv); total=$((total + 1))
  case $b in
    app_produccion)
      (cd ejemplos && exec "$C" app_produccion.cfv) > "$tmp/srv.out" 2>&1 &
      # Esperar el puerto 4000 (0FA0) en escucha sin enviarle peticiones.
      listo=0
      for i in $(seq 1 60); do puerto_escuchando && { listo=1; break; }; sleep 0.25; done
      T="Authorization: Bearer tok_admin_12345"
      { curl -s localhost:4000/salud; echo
        curl -s -X POST localhost:4000/auth/login -d '{"usuario":"admin","contrasena":"cforge123"}'; echo
        curl -s -X POST localhost:4000/auth/login -d '{"usuario":"admin","contrasena":"mala"}'; echo
        curl -s -H "$T" localhost:4000/tareas; echo
        curl -s localhost:4000/metricas; echo
        curl -s localhost:4000/nada; echo; } > "$tmp/http.txt" 2>&1
      detener_programas
      if [ $listo = 1 ] && diff -u ejemplos/salidas/app_produccion.http "$tmp/http.txt"; then ok=$((ok + 1)); else falla "$b" "respuestas HTTP distintas"; fi
      ;;
    trafico_visual)
      if ! hay_sdl; then echo "  · $b: omitido (falta SDL2)"; total=$((total - 1)); continue; fi
      (cd ejemplos && SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-dummy} timeout 3 "$C" "$b.cfv") > "$tmp/out" 2>/dev/null
      rc=$?
      detener_programas
      if [ $rc = 124 ]; then ok=$((ok + 1)); else falla "$b" "el ciclo de SDL terminó (código $rc)"; fi
      ;;
    plataformas)
      if ! hay_sdl; then echo "  · $b: omitido (falta SDL2)"; total=$((total - 1)); continue; fi
      (cd ejemplos && SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-dummy} timeout 10 "$C" "$b.cfv") > "$tmp/out" 2>/dev/null
      echo $? > "$tmp/codigo"
      if diff -u "ejemplos/salidas/$b.salida" "$tmp/out" && diff -q "ejemplos/salidas/$b.codigo" "$tmp/codigo" >/dev/null; then ok=$((ok + 1)); else falla "$b" "salida o código distintos"; fi
      ;;
    *)
      (cd ejemplos && SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-dummy} timeout 10 "$C" "$b.cfv") > "$tmp/out" 2>/dev/null
      echo $? > "$tmp/codigo"
      sed -i "s/random \(.*\): .*/random \1: N/" "$tmp/out"
      if diff -u "ejemplos/salidas/$b.salida" "$tmp/out" && diff -q "ejemplos/salidas/$b.codigo" "$tmp/codigo" >/dev/null; then ok=$((ok + 1)); else falla "$b" "salida o código distintos"; fi
      ;;
  esac
done
rm -rf "$tmp"
echo "  ejemplos/: $ok/$total"
[ "$ok" = "$total" ]
