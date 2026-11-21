#!/usr/bin/env python3
"""tests/navegador/prueba.py COMPILADOR — navegador real (Chromium headless):
el tablero de ejemplos/web/tablero hecho solo en C-Forge (nav_css, nav_html,
nav_al_soltar, nav_al_tecla, nav_evento y --html) arrastra tarjetas entre
columnas y cierra la ventana de detalle con Escape."""
import os, shutil, subprocess, sys, tempfile, threading, http.server, functools
from playwright.sync_api import sync_playwright

CF = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "./cforge")
RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
d = tempfile.mkdtemp()
shutil.copy(os.path.join(RAIZ, "ejemplos/web/tablero/tablero.cfv"), d)
env = dict(os.environ, CFORGE_STDLIB=os.path.join(RAIZ, "stdlib"))
subprocess.run([CF, "build", "tablero.cfv", "--target", "wasm", "--release", "--html", "-o", "tablero"], cwd=d, env=env, check=True, capture_output=True)
assert os.path.exists(os.path.join(d, "tablero.html")), "--html no generó la página"

class Silencioso(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a): pass
srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(Silencioso, directory=d))
threading.Thread(target=srv.serve_forever, daemon=True).start()
url = f"http://127.0.0.1:{srv.server_address[1]}/tablero.html"

def texto(pg, s): return pg.eval_on_selector(s, "e => e.innerText.replace(/\\n/g, ' | ')")
with sync_playwright() as p:
    b = p.chromium.launch(); pg = b.new_page(); errores = []
    pg.on("pageerror", lambda e: errores.append(str(e)))
    pg.goto(url); pg.wait_for_selector("#t1")
    pg.drag_and_drop("#t1", "#c2"); pg.wait_for_timeout(150)
    assert "Diseñar portada" in texto(pg, "#c2"), texto(pg, "#c2")
    pg.drag_and_drop("#t3", "#c0"); pg.wait_for_timeout(150)
    assert "Revisar fotos" in texto(pg, "#c0"), texto(pg, "#c0")
    pg.click("#t1"); pg.wait_for_timeout(100)
    assert pg.eval_on_selector("#detalle", "e => e.classList.contains('abierto')")
    assert pg.inner_text("#detalle-columna") == "Columna: Listo"
    pg.keyboard.press("Enter"); pg.wait_for_timeout(50)
    assert pg.eval_on_selector("#detalle", "e => e.classList.contains('abierto')"), "otra tecla no cierra"
    pg.keyboard.press("Escape"); pg.wait_for_timeout(100)
    assert not pg.eval_on_selector("#detalle", "e => e.classList.contains('abierto')"), "Escape no cerró"
    assert pg.eval_on_selector("#c0", "e => getComputedStyle(e).borderRadius") == "10px", "nav_css"
    assert not errores, errores
    b.close()
srv.shutdown(); shutil.rmtree(d)
print("  ✓ navegador (Chromium): arrastrar y soltar, Escape, nav_evento, nav_css y --html")
