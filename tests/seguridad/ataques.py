#!/usr/bin/env python3
"""Ataques reales contra cforge: paquetes (path traversal), parser (pila),
servidor HTTP (smuggling, cabeceras enormes, Slowloris) y WebSocket (tramas
gigantes, fragmentos sin fin, violaciones de RFC 6455).
Uso: python3 tests/seguridad/ataques.py ./cforge"""
import base64, os, socket, struct, subprocess, sys, tempfile, time

CF = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "./cforge")
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ENV = dict(os.environ, CFORGE_STDLIB=os.path.join(RAIZ, "stdlib"))
fallas = []

def esperar(nombre, cond):
    print(("  ✓ " if cond else "  ✗ ") + nombre)
    if not cond: fallas.append(nombre)

# ── Gestor de paquetes ──
with tempfile.TemporaryDirectory() as d:
    subprocess.run([CF, "init"], cwd=d, env=ENV, capture_output=True)
    for spec in ["evil/../.ssh/authorized_keys@main", "evil/../../../../tmp/evil@ref", "a/b@../../x", "a/b@-uexploit", "-c/x", "../x/y",
                 "a/%2e%2e@x", "a/b%2f..%2f..", "a/b@%5c..%5cx", "a/\\u002e\\u002e/x", "a/b\\..\\x", "a/b\x01", "a/b@v1@v2",
                 "a/b c", "a/b;rm -rf", "a/b@v1\nx", "a/\u00e9b"]:
        r = subprocess.run([CF, "add", spec], cwd=d, env=dict(ENV, CFORGE_HOME=os.path.join(d, "h"), CFORGE_GIT_BASE="/nada/"), capture_output=True, text=True, timeout=30)
        esperar(f"paquete rechazado: {spec}", r.returncode != 0 and "inválid" in (r.stdout + r.stderr) and not os.path.exists(os.path.join(d, "h", "..", ".ssh")))

    # Byte nulo: no cabe en argv, va dentro de cforge.toml (cforge install).
    with open(os.path.join(d, "cforge.toml"), "a") as f: f.write('\n[dependencias]\nx = "a/b\x00/../../h"\n')
    r = subprocess.run([CF, "install"], cwd=d, env=dict(ENV, CFORGE_HOME=os.path.join(d, "h"), CFORGE_GIT_BASE="/nada/"), capture_output=True, text=True, timeout=30)
    esperar("byte nulo en cforge.toml rechazado", r.returncode != 0 and "inválid" in (r.stdout + r.stderr))
    for alias in ["../x", "a/b", "-c", ".."]:
        r = subprocess.run([CF, "add", "a/b", "--como", alias], cwd=d, env=dict(ENV, CFORGE_HOME=os.path.join(d, "h"), CFORGE_GIT_BASE="/nada/"), capture_output=True, text=True, timeout=30)
        esperar(f"alias rechazado: {alias}", r.returncode != 0 and "inválid" in (r.stdout + r.stderr))

# ── Parser: anidamiento extremo ──
with tempfile.NamedTemporaryFile("w", suffix=".cfv", delete=False) as f:
    f.write("mostrar(" + "(" * 200000 + "1" + ")" * 200000 + ")\n")
r = subprocess.run([CF, "check", f.name], env=ENV, capture_output=True, text=True, timeout=60)
esperar("anidamiento de 200 000 paréntesis: error limpio", r.returncode == 1 and "anidamiento" in r.stdout + r.stderr)
os.unlink(f.name)

# ── Servidor HTTP y WebSocket ──
PUERTO = 18000 + os.getpid() % 1000
fuente = f'''importar "red"
sea srv = servidor_http_escuchar({PUERTO})
servidor_http_limites(srv, nulo, 1000, 1500, 2000)
mientras (verdadero) {{
    sea req = servidor_http_solicitud(srv)
    si (ws_es_solicitud(req)) {{
        sea c = ws_aceptar(srv, req)
        intentar {{
            sea m = ws_recibir(c)
            ws_enviar(c, "eco " + longitud(m))
        }} capturar (e) {{ }}
    }} sino {{ servidor_http_responder(srv, 200, "ok " + longitud(req["cuerpo"]), "text/plain") }}
}}
'''
with tempfile.NamedTemporaryFile("w", suffix=".cfv", delete=False) as f:
    f.write(fuente)
srv = subprocess.Popen([CF, f.name], env=ENV, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(1.5)

def http(datos, pausa=None):
    s = socket.create_connection(("127.0.0.1", PUERTO)); s.settimeout(8)
    try:
        if pausa:
            for b in datos: s.send(bytes([b])); time.sleep(pausa)
        else: s.sendall(datos)
        return s.recv(200).split(b"\r\n")[0].decode()
    except Exception as e: return type(e).__name__
    finally: s.close()

def ws(tramas):
    s = socket.create_connection(("127.0.0.1", PUERTO)); s.settimeout(8)
    k = base64.b64encode(os.urandom(16))
    s.sendall(b"GET / HTTP/1.1\r\nHost: x\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: " + k + b"\r\nSec-WebSocket-Version: 13\r\n\r\n")
    s.recv(1000)
    try:
        for t in tramas: s.sendall(t)
        r = s.recv(100)
    except Exception as e: r = type(e).__name__
    s.close(); time.sleep(0.2)
    if isinstance(r, bytes) and r[:1] == b"\x88" and len(r) >= 4: return struct.unpack(">H", r[2:4])[0]
    return r

def trama(op, datos, fin=True, largo=None, rsv=0):
    m = b"abcd"; n = len(datos) if largo is None else largo
    b0 = (128 if fin else 0) | rsv | op
    if n < 126: h = bytes([b0, 128 | n])
    elif n < 65536: h = bytes([b0, 128 | 126]) + struct.pack(">H", n)
    else: h = bytes([b0, 128 | 127]) + struct.pack(">Q", n)
    return h + m + bytes(c ^ m[i % 4] for i, c in enumerate(datos))

try:
    esperar("HTTP normal", http(b"POST / HTTP/1.1\r\nContent-Length: 3\r\n\r\nabc") == "HTTP/1.1 200 OK")
    esperar("CL.TE → 400", http(b"POST / HTTP/1.1\r\nContent-Length: 4\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n").startswith("HTTP/1.1 400"))
    esperar("TE sin soporte → 501", http(b"POST / HTTP/1.1\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n").startswith("HTTP/1.1 501"))
    esperar("Content-Length doble → 400", http(b"POST / HTTP/1.1\r\nContent-Length: 3\r\nContent-Length: 5\r\n\r\nabc").startswith("HTTP/1.1 400"))
    esperar("Content-Length de 23 dígitos → 400", http(b"POST / HTTP/1.1\r\nContent-Length: 99999999999999999999999\r\n\r\n").startswith("HTTP/1.1 400"))
    esperar("cuerpo sobre el límite → 413", http(b"POST / HTTP/1.1\r\nContent-Length: 5000\r\n\r\n").startswith("HTTP/1.1 413"))
    esperar("cabeceras de 10 KB → 431", http(b"GET / HTTP/1.1\r\nX-A: " + b"a" * 10000 + b"\r\n\r\n").startswith("HTTP/1.1 431"))
    t = time.time(); r = http(b"GET / HTTP/1.1\r\nHost: " + b"x" * 40 + b"\r\n", pausa=0.3)
    esperar("Slowloris cortado en menos de 5 s", time.time() - t < 5 and not r.startswith("HTTP/1.1 200"))
    esperar("cliente mudo → 408", http(b"GET / HTTP/1.1\r\n").startswith("HTTP/1.1 408"))
    esperar("el servidor sigue atendiendo", http(b"GET / HTTP/1.1\r\n\r\n") == "HTTP/1.1 200 OK")
    esperar("WebSocket normal", ws([trama(1, b"hola")]) == b"\x81\x05eco 4")
    esperar("trama de 2^62 bytes → 1009", ws([trama(2, b"", largo=2**62)]) == 1009)
    esperar("trama de 2 MiB → 1009", ws([trama(2, b"", largo=2 * 1024 * 1024)]) == 1009)
    esperar("20 fragmentos de 1 MB → 1009", ws([trama(1, b"x" * 1000000, fin=False)] + [trama(0, b"x" * 1000000, fin=False)] * 19) == 1009)
    esperar("bits RSV → 1002", ws([trama(1, b"hola", rsv=64)]) == 1002)
    esperar("ping de 200 bytes → 1002", ws([trama(9, b"p" * 200)]) == 1002)
    esperar("continuación sin inicio → 1002", ws([trama(0, b"hola")]) == 1002)
    esperar("WebSocket sigue atendiendo", ws([trama(1, b"chau")]) == b"\x81\x05eco 4")
finally:
    srv.kill(); os.unlink(f.name)

if fallas:
    print(f"✗ {len(fallas)} ataques no se bloquearon"); sys.exit(1)
print("✓ seguridad: paquetes, parser, HTTP y WebSocket resisten los ataques")
