# Seguridad de C-Forge

Sitio oficial: **[c-forge.org](https://c-forge.org)**

## Versiones

`3.2.x` es la rama estable mantenida y recibe correcciones de seguridad. No posee
certificación regulatoria para entornos críticos. No ejecute scripts `.cfv` desconocidos:
los procesos, archivos y la red pueden acceder a capacidades del sistema.

## Informar vulnerabilidades

No publiques detalles explotables en un issue público. Contacta a
`seguridad@c-forge.org` o `hola@vemorisgroup.com` indicando versión, plataforma,
reproducción mínima e impacto. Vemoris Group debe confirmar recepción, coordinar
una corrección y publicar un aviso cuando exista una versión reparada.

## Controles automatizados

- CodeQL para C++ en cada cambio y semanalmente.
- Compilación sin avisos, pruebas nativas `.cfv`, ASan y UBSan.
- Límites de tamaño, HTTPS y SHA-256 para paquetes.
- Rechazo de enlaces y rutas ascendentes al extraer paquetes.
- Suite multiplataforma en macOS, Ubuntu y Windows.

Estos controles no sustituyen una auditoría independiente.

## Endurecimiento contra entradas hostiles (4.5)

Revisado con una auditoría ofensiva; cada punto tiene una prueba en
`tests/seguridad/` (suite en C-Forge en el gate de las tres plataformas y
`ataques.py` con ataques reales en el CI de Linux):

| Área | Defensa |
|---|---|
| `cforge add` | usuario, repo y `@ref` se validan (sin `..`, `/` sobrante ni `-` inicial); el `principal` de un paquete no puede salir de su carpeta |
| Memoria | `mem_reservar` rechaza tamaños negativos o mayores que 1 TiB |
| Imágenes | máx. 65 535 por lado y 268 megapíxeles; el IDAT de PNG solo puede producir el tamaño esperado; JPEG valida la banda espectral (`Ss`, `Se`, `Ah`, `Al`) y rechaza SOF repetidos |
| zlib / gzip | límite de expansión (256 MiB por defecto, configurable) contra bombas de compresión |
| Secretos | `borrar_texto` y los búferes temporales de la criptografía se borran byte a byte con barrera de memoria (`mfence` / `dmb ish`); los literales no se tocan |
| Ejecutables | se rechazan programas de más de 1 GiB (campos de 32 bits en ELF, PE, Mach-O y la firma); LEB128 sin signo rechaza negativos |
| Servidor HTTP | cabeceras ≤ 8 KiB (431), cuerpo ≤ 16 MiB (413), timeout por lectura y plazo total para las cabeceras (408, anti Slowloris), `Content-Length` + `Transfer-Encoding`, `Content-Length` repetido o no numérico (400), `Transfer-Encoding` sin soporte (501); configurable con `servidor_http_limites` |
| WebSocket | tramas ≤ 1 MiB y mensajes ≤ 16 MiB antes de reservar (1009), bits RSV, opcodes, tramas de control y continuaciones según RFC 6455 (1002); `ws_limites` |
| TLS | TLS 1.2 como mínimo; en 1.2 solo suites ECDHE con AES-GCM o ChaCha20-Poly1305 (OpenSSL); TLS 1.2 fijo en Schannel |
| Fuentes TrueType | tablas dentro del archivo, índices de glifo y contornos validados |
| Parser | anidamiento máximo de 1000 niveles (antes, un archivo con 200 000 paréntesis tumbaba el compilador) |
| Runtime | `byte_en` fuera de rango lanza un error capturable en vez de abortar |

