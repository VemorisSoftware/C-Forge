#!/usr/bin/env python3
"""tests/lsp/prueba.py COMPILADOR — prueba de punta a punta de "cforge lsp":
initialize, diagnósticos (sin errores y con error en la línea correcta),
ir a la definición, información, autocompletado (documento + runtime +
palabras clave), formateo y cierre."""
import json, os, subprocess, sys, tempfile

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

C = os.path.abspath(sys.argv[1])
raiz = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
d = tempfile.mkdtemp()
ruta = os.path.join(d, "doble.cfv")
texto = "funcion doble(x: numero): numero {\n    retornar x * 2\n}\n\nsea total = doble(4)\nmostrar(total)\n"
open(ruta, "w").write(texto)
p = subprocess.Popen([C, "lsp"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     env=dict(os.environ, CFORGE_STDLIB=os.path.join(raiz, "stdlib")))

def enviar(m):
    b = json.dumps(m).encode()
    p.stdin.write(b"Content-Length: %d\r\n\r\n" % len(b) + b)
    p.stdin.flush()

def leer():
    h = b""
    while not h.endswith(b"\r\n\r\n"):
        c = p.stdout.read(1)
        assert c, "el servidor cerró la salida"
        h += c
    n = int(h.split(b":")[1].split(b"\r")[0])
    return json.loads(p.stdout.read(n))

def peticion(i, metodo, params):
    enviar({"jsonrpc": "2.0", "id": i, "method": metodo, "params": params})
    while True:
        r = leer()
        if r.get("id") == i:
            return r["result"]

def cambiar(t, v):
    enviar({"jsonrpc": "2.0", "method": "textDocument/didChange",
            "params": {"textDocument": {"uri": uri, "version": v}, "contentChanges": [{"text": t}]}})
    return leer()["params"]["diagnostics"]

uri = "file://" + ("/" if ruta[1:2] == ":" else "") + ruta.replace("\\", "/")
caps = peticion(1, "initialize", {"capabilities": {}})["capabilities"]
assert caps["definitionProvider"] and caps["documentFormattingProvider"], caps
enviar({"jsonrpc": "2.0", "method": "initialized", "params": {}})
enviar({"jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": {"textDocument": {"uri": uri, "languageId": "cforge", "version": 1, "text": texto}}})
assert leer()["params"]["diagnostics"] == []
diag = cambiar(texto.replace("x * 2", "x * )"), 2)
assert len(diag) == 1 and diag[0]["range"]["start"]["line"] == 1, diag
assert cambiar(texto, 3) == []
defi = peticion(2, "textDocument/definition", {"textDocument": {"uri": uri}, "position": {"line": 4, "character": 14}})
assert defi["range"]["start"] == {"line": 0, "character": 8}, defi
hover = peticion(3, "textDocument/hover", {"textDocument": {"uri": uri}, "position": {"line": 4, "character": 14}})
assert "funcion doble(x: numero): numero" in hover["contents"]["value"], hover
etiquetas = [i["label"] for i in peticion(4, "textDocument/completion", {"textDocument": {"uri": uri}, "position": {"line": 5, "character": 3}})]
for e in ("doble", "total", "longitud", "mostrar", "mientras"):
    assert e in etiquetas, e
cambiar("si(1){\nmostrar(1,2)\n}\n", 4)
edicion = peticion(5, "textDocument/formatting", {"textDocument": {"uri": uri}, "options": {"tabSize": 4, "insertSpaces": True}})
assert edicion[0]["newText"] == "si (1) {\n    mostrar(1, 2)\n}\n", edicion
peticion(6, "shutdown", None)
enviar({"jsonrpc": "2.0", "method": "exit"})
assert p.wait(timeout=10) == 0
print("  ✓ cforge lsp: diagnósticos, definición, información, autocompletado y formateo")
