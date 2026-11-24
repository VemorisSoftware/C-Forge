#!/usr/bin/env python3
"""Genera las páginas de c-forge.org a partir de plantillas y datos del repo.

Todo lo que el sitio afirma sale de una fuente verificable:
  - versión ............ Makefile (VERSION)
  - estado ............. capabilities.json
  - novedades .......... data/releases.json
  - ejemplos ........... ejemplos/*.cfv y su salida real ejemplos/*.salida
                         (verificar.sh los ejecuta en CI)

Uso:
  python3 site/generar.py           # regenera index.html y aprende.html
  python3 site/generar.py --check   # falla si las páginas no están al día
"""
import html
import json
import re
import sys
from pathlib import Path

SITIO = Path(__file__).resolve().parent
RAIZ = SITIO.parent
# (plantilla, destino, idioma)
PAGINAS = [
    ("es/index.html", "index.html", "es"),
    ("es/aprende.html", "aprende.html", "es"),
    ("es/404.html", "404.html", "es"),
    ("en/index.html", "en/index.html", "en"),
    ("en/learn.html", "en/learn.html", "en"),
]

PALABRAS = {
    "sea", "funcion", "retornar", "si", "sino", "mientras", "para", "en",
    "intentar", "capturar", "lanzar", "clase", "esto", "importar", "romper",
    "continuar", "y", "o", "no",
    "let", "function", "return", "if", "else", "while", "for", "in", "try",
    "catch", "throw", "class", "this", "import", "break", "continue", "and",
    "or", "not",
}
LITERALES = {"verdadero", "falso", "nulo", "true", "false", "null"}
TOKEN = re.compile(
    r'(?P<c>//[^\n]*)|(?P<s>"(?:\\.|[^"\\])*")|(?P<n>\b\d+(?:\.\d+)?\b)'
    r'|(?P<id>[A-Za-z_áéíóúñÁÉÍÓÚÑ][\wáéíóúñÁÉÍÓÚÑ]*)(?P<llamada>\s*\()?'
)

ESTADOS = {
    "verified-stable": ("estable", {"es": "Estable", "en": "Stable"}),
    "experimental": ("experimental", {"es": "Experimental", "en": "Experimental"}),
    "partial": ("parcial", {"es": "En desarrollo", "en": "In progress"}),
    "planned": ("planificado", {"es": "Planificado", "en": "Planned"}),
    "not-certified": ("no-certificado", {"es": "No certificado", "en": "Not certified"}),
}
SALIDA = {"es": "Salida", "en": "Output"}


def resaltar(codigo: str) -> str:
    salida, pos = [], 0
    for m in TOKEN.finditer(codigo):
        salida.append(html.escape(codigo[pos:m.start()]))
        pos = m.end()
        if m.group("c"):
            salida.append(f'<span class="c">{html.escape(m.group("c"))}</span>')
        elif m.group("s"):
            salida.append(f'<span class="s">{html.escape(m.group("s"))}</span>')
        elif m.group("n"):
            salida.append(f'<span class="n">{m.group("n")}</span>')
        else:
            palabra, llamada = m.group("id"), m.group("llamada") or ""
            if palabra in PALABRAS:
                clase = "k"
            elif palabra in LITERALES:
                clase = "b"
            elif llamada:
                clase = "f"
            else:
                clase = ""
            texto = html.escape(palabra)
            salida.append(f'<span class="{clase}">{texto}</span>' if clase else texto)
            salida.append(html.escape(llamada))
    salida.append(html.escape(codigo[pos:]))
    return "".join(salida)


def ejemplo(nombre: str, idioma: str, con_salida: bool = True) -> str:
    fuente = (SITIO / "ejemplos" / f"{nombre}.cfv").read_text(encoding="utf-8").rstrip()
    archivo = nombre.split("/")[-1]
    partes = [
        '<figure class="codigo">',
        f'<figcaption class="codigo-barra"><span class="puntos"><i></i><i></i><i></i></span>{archivo}.cfv</figcaption>',
        f"<pre><code>{resaltar(fuente)}</code></pre>",
    ]
    if con_salida:
        salida = (SITIO / "ejemplos" / f"{nombre}.salida").read_text(encoding="utf-8").rstrip()
        partes += [
            f'<div class="salida"><div class="salida-titulo">{SALIDA[idioma]}</div>',
            f"<pre><samp>{html.escape(salida)}</samp></pre></div>",
        ]
    partes.append("</figure>")
    return "".join(partes)


def version() -> str:
    m = re.search(r"^VERSION\s*:=\s*(\S+)", (RAIZ / "Makefile").read_text(), re.M)
    return m.group(1)


def tabla_estado(idioma: str) -> str:
    datos = json.loads((RAIZ / "capabilities.json").read_text(encoding="utf-8"))
    sufijo = "" if idioma == "es" else "_" + idioma
    filas = []
    for cap in datos["capabilities"]:
        clase, etiquetas = ESTADOS[cap["status"]]
        filas.append(
            f'<tr><td>{html.escape(cap["name" + sufijo])}</td>'
            f'<td><span class="estado estado-{clase}">{etiquetas[idioma]}</span></td>'
            f'<td>{html.escape(cap["scope" + sufijo])}</td></tr>'
        )
    return "\n".join(filas)


def novedades(idioma: str) -> str:
    datos = json.loads((SITIO / "data" / "releases.json").read_text(encoding="utf-8"))
    rel = next(r for r in datos["releases"] if r["version"] == datos["latest"])
    tipos = {
        "es": {"new": "Nuevo", "fix": "Arreglo", "change": "Cambio"},
        "en": {"new": "New", "fix": "Fix", "change": "Change"},
    }[idioma]
    sufijo = "" if idioma == "es" else "_" + idioma
    items = []
    fecha = rel["date_display" if idioma == "es" else "date_display_" + idioma]
    for c in rel["changelog"]:
        items.append(
            f'<article class="novedad r"><p><b>{html.escape(c["title" + sufijo])}:</b> {html.escape(c["desc" + sufijo])}</p>'
            f'<div class="novedad-meta"><span class="novedad-tipo">{tipos.get(c["type"], c["type"])} · v{rel["version"]}</span>'
            f'<span>{html.escape(fecha)}</span></div></article>'
        )
    return "\n".join(items)


def modulos_stdlib() -> int:
    return len(list((RAIZ / "stdlib").glob("*.cfv")))


def pruebas() -> int:
    return len(list((RAIZ / "tests" / "cfv").glob("*.cfv")))


def renderizar(plantilla: str, idioma: str) -> str:
    v = version()
    datos = json.loads((SITIO / "data" / "releases.json").read_text(encoding="utf-8"))
    actual = next(r for r in datos["releases"] if r["version"] == datos["latest"])
    reemplazos = {
        "version": v,
        "estado": tabla_estado(idioma),
        "novedades": novedades(idioma),
        "modulos": str(modulos_stdlib()),
        "pruebas": str(pruebas()),
        "fecha": actual["date_display" if idioma == "es" else "date_display_" + idioma],
        "mascota": (SITIO / "plantillas" / "mascota.svg").read_text(encoding="utf-8").strip(),
    }

    def sustituir(m):
        clave = m.group(1)
        if clave.startswith("ejemplo:"):
            return ejemplo(clave.split(":", 1)[1], idioma)
        if clave.startswith("codigo:"):
            return ejemplo(clave.split(":", 1)[1], idioma, con_salida=False)
        if clave not in reemplazos:
            raise KeyError(f"marcador desconocido: {{{{{clave}}}}}")
        return reemplazos[clave]

    return re.sub(r"\{\{([a-z:_/-]+)\}\}", sustituir, plantilla)


def main() -> int:
    comprobar = "--check" in sys.argv
    desactualizadas = []
    for origen, nombre, idioma in PAGINAS:
        plantilla = (SITIO / "plantillas" / origen).read_text(encoding="utf-8")
        resultado = renderizar(plantilla, idioma)
        destino = SITIO / nombre
        destino.parent.mkdir(parents=True, exist_ok=True)
        if comprobar:
            if not destino.exists() or destino.read_text(encoding="utf-8") != resultado:
                desactualizadas.append(nombre)
        else:
            destino.write_text(resultado, encoding="utf-8")
            print(f"  GEN  site/{nombre}")
    if desactualizadas:
        print("Páginas desactualizadas (ejecuta python3 site/generar.py):", ", ".join(desactualizadas))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
