"""Ejecuta tests/red/prueba.cfv con servidores locales. Uso: prueba.py [cforge]"""
import json, os, subprocess, sys, tempfile
sys.stdout.reconfigure(encoding="utf-8")
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import servidores

cforge = sys.argv[1] if len(sys.argv) > 1 else "./cforge"
puertos = servidores.iniciar()
archivo = os.path.join(tempfile.gettempdir(), "cforge-red-puertos.json")
with open(archivo, "w") as f: json.dump(puertos, f)
# Schannel (Windows) usa el almacén de Windows: la CA de prueba no es de confianza.
confiar = "confiar" if os.name != "nt" else "no"
entorno = dict(os.environ, SSL_CERT_FILE=os.path.join(AQUI, "certs", "ca.pem"))
r = subprocess.run([cforge, os.path.join(AQUI, "prueba.cfv"), archivo, confiar], capture_output=True, timeout=180, env=entorno)
salida = r.stdout.decode("utf-8", "replace").replace("\r\n", "\n")
esperado = open(os.path.join(AQUI, "prueba.salida" if confiar == "confiar" else "prueba_windows.salida"), encoding="utf-8").read()
if r.returncode != 0 or salida != esperado:
    print(salida); print(r.stderr.decode("utf-8", "replace"))
    import difflib
    print("".join(difflib.unified_diff(esperado.splitlines(True), salida.splitlines(True), "esperado", "obtenido")))
    print("  ✗ tests/red"); sys.exit(1)
print("  ✓ red: HTTP (chunked, redirección, POST), UDP, Redis, DNS, HTTPS y WebSocket")
if os.environ.get("CFORGE_TLS_INTERNET"):
    t = subprocess.run([cforge, os.path.join(AQUI, "internet.cfv")], capture_output=True, timeout=120)
    s = t.stdout.decode("utf-8", "replace").strip()
    if t.returncode != 0 or s != "200 verdadero":
        print(s, t.stderr.decode("utf-8", "replace")); print("  ✗ HTTPS a Internet"); sys.exit(1)
    print("  ✓ HTTPS a Internet con el almacén de certificados del sistema")
