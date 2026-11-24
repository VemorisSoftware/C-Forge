"""Módulo de ejemplo para las pruebas de sintaxis."""
import os, sys as sistema
from collections import defaultdict, OrderedDict as OD
from . import hermano
from ..paquete.mod import (a, b as c)

CONSTANTE: int = 42
ñandú = "acentos y ñ"


@decorador
@otro.decorador(1, clave="v")
class Figura(Base, metaclass=Meta):
    """Una figura."""
    lados = 0

    def __init__(self, nombre: str, *args, color="rojo", **kw) -> None:
        self.nombre = nombre  # comentario al final
        self.puntos = [(x, y) for x in range(3) for y in range(x) if x != y]
        self.mapa = {k: v ** 2 for k, v in kw.items()}
        # comentario suelto

    @property
    def area(self):
        return 0.5 * self.lados ** 2 if self.lados else -1

    async def cargar(self, ruta, /, *, modo="r"):
        async with abrir(ruta, modo) as f:
            datos = await f.leer()
        return datos


def generador(n):
    i = 0
    while i < n:
        yield i
        i += 1
    else:
        pass
    yield from otro()


def procesa(items):
    total, *resto = items
    try:
        valor = items[1:-1:2]
        valor = items[::2, 0]
    except (KeyError, IndexError) as e:
        raise ValueError("malo") from e
    except Exception:
        del items[0], total
    else:
        assert total >= 0, "negativo"
    finally:
        global CONTADOR
    for (i, j) in enumerate(items):
        if i % 2 == 0 and not j or i is None:
            continue
        elif i in resto and j not in resto:
            break
        else:
            print(f"{i!r:>4} y {j:{ancho}} {{literal}}", end="")
    s = {1, 2, *resto}
    t = (1,)
    u = ()
    v = (yield)
    w = lambda x, y=2, *z: x + y
    x = (n := len(items))
    y = b"bytes" rb'\d' "con\tescape\n" 'otra'
    z = 0x1F + 0o17 + 0b101 + 1_000 + 3.14e-2 + .5 + 2j
    a = ~x | y & z ^ 1 << 2 >> 3 // 4 % 5 @ m
    b = x if y else z if w else None
    c = [*a, *b]
    d = {**a, "k": True, 'f': False}
    e = ...
    a.b.c = d[e](f)(g)[h]
    a = b = c = 0
    nonlocal_x = 1
    return a, b
# final
