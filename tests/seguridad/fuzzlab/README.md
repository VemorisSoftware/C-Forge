# 🔬 Fuzz Lab de C-Forge

Laboratorio de ataques automáticos de Vemoris Software. Bombardea C-Forge con miles de entradas hostiles para encontrar cierres, cuelgues y errores antes que nadie. No usa IA: es fuerza bruta y no cuesta nada.

## Qué ataca

| Motor | Qué hace |
|---|---|
| **stdlib** | JSON, Base64, URL, CSV, regex, XML, Markdown, números, LZ4, Snappy, Zstd, zlib, PNG y textos con entradas aleatorias, mutadas y patológicas (`ataques_stdlib.cfv`) |
| **programas** | Programas de estrés generados: recursión profunda, enteros gigantes, memoria, closures, excepciones, a veces con el GC en estrés (`generador.cfv`) |
| **mutaciones** | Programas reales de `tests/cfv` y `ejemplos` con mutaciones, en el compilador y al ejecutar |
| **bytes** | Bytes aleatorios al compilador |

Una **falla** es: cierre por señal (segfault, abort, sin memoria), cuelgue o un error que `intentar/capturar` no atrapa. Los errores normales de C-Forge no cuentan como falla.

## Usarlo

```sh
make build
sh tests/seguridad/fuzzlab/fuzzlab.sh 30 salida   # 30 minutos de ataques
```

El reporte queda en `salida/REPORTE.md` y los reproductores en `salida/casos/`.

## Automático en GitHub

`.github/workflows/fuzz-lab.yml` lo corre cada 6 horas, en tandas de 5,5 horas. Si encuentra fallas, abre o actualiza un issue con la etiqueta **fuzz-lab**.

**Para pararlo:** Settings → Secrets and variables → Actions → Variables → `FUZZ_LAB_ACTIVO` = `no`.
