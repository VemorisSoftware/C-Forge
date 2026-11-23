# Changelog — C-Forge

Sitio oficial: [c-forge.org](https://c-forge.org)

## Sin publicar

- **Corregido:** `esperar(t)` podía quedarse colgada para siempre si la
  tarea terminaba justo entre la comprobación y la espera del futex (volvía
  a leer el tid y esperaba con 0). Ahora espera con el mismo valor que
  comprobó.
- **Bibliotecas del ecosistema (lote 1):** `tinta` (colores ANSI, NO_COLOR),
  `ident` (UUID v4/v7, ULID, NanoID), `csv` (RFC 4180, exportación segura
  contra fórmulas), `progreso` (barras y spinners) y `dinero` (decimales
  exactos, redondeo bancario, reparto sin perder centavos). Pruebas en
  `tests/bibliotecas` (normal y `--release`).
- **Bilingües:** `import "ink"`, `"ids"`, `"progress"`, `"money"` y los
  nombres en inglés de `csv` (`csv_read`, `csv_write`…); `money_round`
  acepta `"even"` y `"up"`. Pruebas escritas en inglés.
- **Lote 2 (bilingüe):** `marcado`/`markdown` (Markdown a HTML sin HTML
  crudo ni enlaces `javascript:`/`data:`), `orden`/`cli` (opciones, banderas,
  posicionales y ayuda automática), `bitacora`/`logger` (niveles, texto o
  JSON, sin inyección de líneas), `resiste`/`resilience` (reintentos con
  espera exponencial y cortacircuitos) y `plantilla`/`template` (`{{ }}`
  escapado, `#si`/`#if`, `#cada`/`#each`). Pruebas en español e inglés.
- **Lote 8 (bilingüe):** `traza`/`tracing` (spans, W3C traceparent, OTLP),
  `cobro`/`payments` (idempotencia, webhooks firmados, estados de pago),
  `ciencia`/`science` (Nelder–Mead, Levenberg–Marquardt, splines, RK4),
  `simbolo`/`symbolic` (derivadas, simplificación, LaTeX), `astro`/`astronomy`
  (salida y puesta del sol, fases de la Luna, estaciones), `archivador`/
  `archive` (ZIP y TAR contra zip slip y bombas), `hoja`/`xlsx` (crear
  .xlsx) y `lee_excel`/`read_xlsx` (leer .xlsx); probados contra unzip, tar
  y openpyxl.
- **Lote 9 (bilingüe):** `fourier`/`fft` (cualquier largo, espectros,
  filtros, convolución), `sobre`/`envelope` (cifrado a claves públicas o con
  contraseña, por bloques), `mensaje_bancario`/`iso8583` (ISO 8583 con PAN
  enmascarado), `infra`/`hcl` (configuración estilo HCL), `multitud`/`crowd`
  (bandadas y multitudes sin choques), `grafica`/`chart` (líneas, barras,
  torta y dispersión en SVG), `secretos`/`secrets` (valores cifrados en JSON
  y .env) y `alerta`/`errors` (reporte de errores compatible con Sentry).
- **Lote 10 (bilingüe):** `estadistica`/`stats` (t de Student, Welch,
  pareada, χ², ANOVA, Pearson, intervalos; contra SciPy), `gradiente`/
  `autograd` (autodiferenciación en modo reverso, redes con Adam o SGD),
  `vela`/`trees` (árboles, bosques aleatorios, Naive Bayes gaussiano y de
  texto), `hibrida`/`hybrid` (BM25 + vectores con RRF, para RAG), `molde`/
  `serde` (serialización con esquema a JSON, CSV, query string y binario,
  con migraciones), `genoma`/`bio` (FASTA/FASTQ, traducción, ORFs,
  Needleman–Wunsch y Smith–Waterman), `registro`/`logging` (fachada con
  niveles por jerarquía, destinos, rotación y contexto) y `planilla`/`pivot`
  (pivote, melt, ventanas móviles, rangos; contra Pandas).
- **Lote 11 (bilingüe):** `codigo_qr`/`qrcode` (QR 1–40 idéntico a
  python-qrcode, EAN-13, UPC-A y Code 128; leídos con ZXing),
  `panal`/`hexgrid` (hexágonos de igual área en todo el planeta, sin
  costura en el antimeridiano, y grillas planas con A*), `malla_geo`/
  `geometry2d` (Delaunay como SciPy, Voronoi, orejas, recorte, Welzl),
  `unicode`/`unicode_en` (NFC/NFD, mayúsculas con ß e İ, grafemas, ancho y
  orden en español), `agenda`/`schedule` (zonas TZif y POSIX, cron que
  respeta el cambio de hora; contra Python zoneinfo), `consulta_archivos`/
  `sqlfiles` (SQL con JOIN, GROUP BY y parámetros sobre CSV y JSON),
  `entidades`/`entities` (ECS con conjuntos dispersos y señales) y
  `federa`/`oidc` (PKCE, state, nonce y validación de ID tokens RS256,
  EdDSA y HS256).
- **Lote 12 (bilingüe):** `curva`/`secp256k1` (ECDSA RFC 6979, recuperar
  clave, Schnorr BIP-340; contra python-ecdsa y los vectores oficiales),
  `semilla`/`hdwallet` (BIP-39 en inglés y español, BIP-32, direcciones
  P2PKH, bech32 y Taproot), `cadena`/`evm` (Keccak, EIP-55, RLP, ABI,
  transacciones EIP-155 y EIP-1559 idénticas a eth_account),
  `apreton`/`noise_protocol` (Noise XX/IK/KK… byte a byte como
  noiseprotocol), `objetos`/`s3` (SigV4 con los ejemplos de AWS),
  `llamada`/`protobuf` (.proto, binario como protoc, marcos gRPC),
  `recolecta`/`crawler` (cookies RFC 6265, formularios, robots.txt,
  rastreo) y `sensor`/`mqtt` (paquetes MQTT, QoS 2, mini broker).
- Lote 30 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `directo`/`webrtc` (WebRTC propio: ICE con STUN, DTLS 1.2 cliente y
  servidor con cookies y retransmisión, SCTP con fragmentación y
  retransmisión, canales de datos DCEP, SDP de oferta y respuesta, y SRTP
  con claves del exportador DTLS. Interopera con aiortc en los dos sentidos;
  el DTLS, con OpenSSL; el SRTP da los mismos bytes que libsrtp).
- Lote 29 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `rayo_json`/`simdjson` (JSON bajo demanda con punteros RFC 6901 que salta
  lo que no se pide con búsquedas nativas, validación estricta con línea,
  columna y UTF-8, minificado, NDJSON y un parser completo unas 8 veces más
  rápido que `json_parsear` en documentos grandes), `trazo`/`vello`
  (vectores al estilo Vello: escena codificada, aplanado con la fórmula de
  Wang, expansión de trazos, mosaicos de 16×16 con cobertura por área,
  degradados lineal/radial/cónico, capas con recorte y 12 modos de mezcla;
  comparado con librsvg), `nativa`/`iced` (GUI reactiva al estilo Iced:
  arquitectura Elm, disposición flex y rejilla, entradas con cursor y
  selección, casillas, radios, interruptores, deslizadores, selectores,
  desplazamiento y suscripciones, probada sin ventana) y
  `escritorio`/`avalonia` (XAML con estilos por selector, enlaces de datos
  de dos vías, comandos, plantillas, Grid, DockPanel y StackPanel sobre
  `nativa`).
- `panel_dibujar` respeta el tamaño de texto de cada comando ("tam").
- Lote 28 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `malla`/`libp2p` (libp2p propio: identidad Ed25519 y PeerId, multiaddr,
  multistream-select, Noise XX con la firma de libp2p, yamux, identify,
  ping y protocolos propios; interopera con js-libp2p en los dos sentidos)
  y `analiza`/`code_analysis` (el compilador como servicio: tokens, árbol
  con recuperación de errores, diagnósticos, definición, referencias,
  completado, información, renombrar, símbolos y plegado; lee los 405
  módulos de la stdlib sin errores de sintaxis) y `solido`/`jolt` (física
  3D de cuerpos rígidos: esferas, cajas, cápsulas y planos, contactos con
  SAT y recorte, solver con arranque en caliente, fricción y rebote,
  restricciones de punto, distancia/cuerda, bisagra con límites y fija,
  islas, sueño, rayos y consultas por esfera).
- `aes_gcm_cifrar` y `aes_gcm_descifrar` aceptan claves de 16 bytes
  (AES-128-GCM) además de las de 32.
- Lote 27 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `blindaje`/`rustls` (TLS 1.3 propio, cliente y servidor sin E/S o sobre
  TCP: X25519 y P-256/P-384, AES-GCM y ChaCha20-Poly1305, firmas Ed25519,
  ECDSA y RSA PSS/PKCS#1, X.509 con cadena hasta las raíces del sistema,
  SNI, ALPN, HelloRetryRequest, KeyUpdate, exportador, modo QUIC y
  certificados propios; probado contra OpenSSL en los dos sentidos) y
  `veloz`/`quinn` (QUIC v1 y HTTP/3 propios sobre `blindaje`: protección de
  paquetes y cabeceras, ACK, retransmisión, flujos con control de flujo,
  Retry, QPACK estático con Huffman, cliente y servidor sobre UDP; probado
  contra aioquic en los dos sentidos).
- `aes_bloque(clave, bloque)`: un bloque AES-128 o AES-256 (ECB).
- Lote 26 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `panel`/`imgui` (GUI de modo inmediato al estilo de Dear ImGui: ventanas
  que se mueven, pliegan, apilan y desplazan, y los elementos de siempre,
  con lista de comandos de dibujo para cualquier motor), `mini_gui`/`nuklear`
  (al estilo de Nuklear, con filas dinámicas y estáticas y propiedades) y
  `pines`/`gpio` (GPIO por el uAPI v2 del kernel, I2C, SPI y PWM, con
  simulador, el conector de la Raspberry Pi y controladores de BME280 y
  SSD1306), `mezcla_mp3`/`mp3` (decodificador MP3 propio: MPEG-1, 2 y 2.5
  capa III, CBR y VBR, estéreo conjunto, bloques cortos, ID3v2 y recorte
  sin huecos de LAME; difiere en a lo más 1 de 32767 de ffmpeg) y
  `mezcla_vorbis`/`vorbis` (decodificador Ogg Vorbis propio con IMDCT por
  FFT, etiquetas y largo exacto por el gránulo). `mezcla_abrir` ahora abre
  también MP3 y Ogg Vorbis.
- Lote 25 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `nucleo`/`ebpf` (máquina virtual de eBPF: ensamblador, desensamblador,
  verificador, intérprete exacto de 64 bits, mapas, ayudas y carga de ELF
  de clang; 1800 programas al azar dan lo mismo que el kernel de Linux) y
  `jit`/`jit_asm` (IR de bloques a código máquina x86-64 y ARM64, con
  compilador de expresiones; se ejecuta en Linux x86-64) e
  `intermedio`/`ssa_ir` (SSA al estilo LLVM: lector, verificador,
  intérprete, mem2reg, plegado, CSE, LICM, código muerto, simplificar el
  grafo y bajada a `jit`).
- Lote 24 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `sombreador`/`shader` (WGSL a GLSL 450 y ES 3.0, MSL, HLSL y WGSL con
  comprobación de tipos y reflexión; las salidas de los shaders de
  ejemplo de wgpu pasan glslangValidator y naga), `manipulador`/`gizmo3d`
  (gizmos 3D de mover, rotar y escalar al estilo ImGuizmo, sin GUI),
  `atributo`/`hypermedia` (runtime propio al estilo htmx, probado con
  jsdom, y ayudas de servidor), `teclado`/`input_sim` (simular teclado y
  ratón: X11 con XTest, macOS y Windows) y `tunel`/`wireguard` (protocolo
  de WireGuard con BLAKE2s propio, cookies y ventana anti-repetición;
  interopera con boringtun como iniciador y como respondedor) y
  `certifica`/`acme` (ACME RFC 8555 con ECDSA P-256 propio, CSR y PEM;
  emite y revoca certificados de punta a punta contra Pebble).
- Lote 23 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `enjambre`/`parallel` (paralelismo de datos al estilo Rayon: mapear,
  filtrar, reducir y ordenar en hilos), `marea`/`asyncrt` (tareas, canales,
  select, difusión, semáforos, barreras y cancelación al estilo Tokio),
  `torrente`/`pipeline` (tuberías de manejadores y códecs al estilo Netty,
  con canal embebido para probar), `pizarra`/`canvasobjects` (objetos
  interactivos al estilo Fabric.js: arrastrar, escalar, girar, deshacer y
  JSON), `animacion`/`lottie` (reproductor de Lottie, cruzado con
  python-lottie), `anillo`/`iouring` (io_uring sin liburing: archivos,
  sockets, temporizadores, cadenas y cancelación) y
  `esqueleto`/`skeleton2d` (esqueletos de Spine 3.8 y 4.x con IK, pieles,
  mallas con pesos, atlas y mezclas entre animaciones).
- Lote 22 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `piloto`/`browser` (automatizar Chrome por DevTools al estilo Playwright,
  probado con Google Chrome), `mapeador`/`dbmapper` (ORM sobre SQLite con
  migraciones generadas, relaciones y seguimiento de cambios),
  `determinista`/`fixedphysics` (física 2D en punto fijo, reproducible bit
  a bit, con capturas para rollback), `importa3d`/`meshio` (STL, PLY, OFF,
  OBJ, glTF y 3MF, cruzado con trimesh) y `nodos`/`scenetree` (árbol de
  escena con señales al estilo Godot).
- Lote 21 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `vector`/`vectorgfx` (dibujo al estilo Cairo con salida SVG, PDF y PNG;
  las tres coinciden con rsvg-convert y pdftoppm), `voz_activa`/`vad` (port
  bit a bit del VAD de WebRTC: mismas decisiones que py-webrtcvad),
  `grafia`/`shaping` (moldeado OpenType con GSUB y GPOS, igual que
  HarfBuzz en 45 casos con 5 fuentes), `latido`/`eventloop` (bucle de
  eventos con temporizadores, tubos y TCP sin bloqueo) y `depura`/`dap`
  (cliente del Debug Adapter Protocol, probado contra debugpy).
- Lote 20 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `memoria_rapida`/`redisx` (Redis con RESP3 y clústeres: ranuras, MOVED y
  ASK, tuberías por nodo; probado contra un clúster real), `cartero`/
  `httpclient` (cliente HTTP con interceptores, reintentos y cancelación),
  `bus`/`dbus` (D-Bus completo, interopera con dbus-daemon y dbus-python),
  `contenedor`/`docker` (API del motor de Docker, probada contra dockerd),
  `entorno`/`testcontainers` (contenedores desechables para pruebas) y
  `senal`/`signalr` (cliente de SignalR probado contra ASP.NET Core 8).
- Lote 19 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `cofre`/`embeddb` (base B+tree ACID con copia en escritura y recuperación
  ante caídas), `huesped`/`wasm` (intérprete de WebAssembly, igual que
  Wasmtime), `centinela`/`suricata` (pcap/pcapng y reglas tipo Suricata),
  `buzon`/`zeromq` (ZMTP 3.0, interopera con libzmq) y
  `correo_rapido`/`nats` (cliente NATS probado contra nats-server).
- Lote 18 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `columnas`/`columnar` (Parquet con páginas v1 y v2, diccionario y
  compresión snappy/gzip/zstd/lz4, y Arrow IPC en flujo y archivo; se
  cruzan con pyarrow en ambos sentidos), `empaca`/`bundler` (empaquetador
  de JavaScript con módulos ES y CommonJS, node_modules y "exports",
  enlaces vivos, IIFE/CJS/ESM y compactado; la salida corre en Node igual
  que el original), `optimalla`/`meshopt` (remapeo y fetch idénticos a
  meshoptimizer, caché de vértices de Forsyth y simplificación cuádrica),
  `textura`/`texcompress` (BC1, BC3, BC4, BC5 y ETC1 con DDS y KTX; los
  decodificadores coinciden con texture2ddecoder), `colas`/`amqp` (AMQP
  0-9-1 byte a byte igual que pamqp, con cliente completo),
  `orquesta`/`kubernetes` (kubeconfig, rutas, CRUD, parches, escalar,
  logs, aplicar y watch) y `descubre`/`discovery` (etcd v3 y Consul).
- Lote 17 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `espacial`/`audio3d` (audio 3D con los modelos de distancia, conos y
  Doppler de OpenAL 1.1, paneo con retardo entre oídos y reverberación),
  `mezcla`/`mixer` (FLAC propio para leer y escribir, probado contra
  ffmpeg, y mezcla de pistas con fundidos, paneo y remuestreo),
  `serie`/`serialport` (puertos serie por termios, analizadores de tramas,
  SLIP, COBS y Modbus RTU), `archivo_kv`/`kvstore` (clave-valor en disco
  con árbol LSM, WAL, Bloom, compactación e instantáneas),
  `sin_copia`/`flatbuffers` (esquemas .fbs y formato FlatBuffers, leído y
  escrito igual que la biblioteca oficial), `carga3d`/`gltf` (glTF 2.0 y
  GLB, con salida que pasa el validador de Khronos), `vecinos`/`zeroconf`
  (mDNS y DNS-SD) y `puertos`/`portmap` (UPnP IGD y NAT-PMP).
- Lote 16 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `compacta`/`compress` (zstd completo para descomprimir con FSE, Huffman,
  diccionarios y varios marcos; LZ4 de bloque y marco; Snappy; gzip con
  inflate propio; crc32, adler32 y xxh32; probado contra zstandard, lz4,
  cramjam y gzip de Python), `terminal`/`tui` (búfer, diseño por
  restricciones y widgets al estilo Ratatui), `recolector`/`logpipe`
  (fuentes, transformaciones con un lenguaje remap y destinos como
  Elasticsearch y Loki, al estilo Vector), `proxy`/`reverseproxy` (rutas,
  balanceo round robin/ponderado/menos conexiones/hash de IP, reintentos,
  salud pasiva y activa, límite por cliente y caché), `proceso`/`workflow`
  (flujos durables con historial, temporizadores, señales, sagas y
  versionado, al estilo Temporal) y `conversor`/`docconvert` (markdown,
  html y texto hacia html, LaTeX, markdown, texto, rst, asciidoc y json;
  html igual a markdown-it en los casos de CommonMark).
- Lote 15 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `correo`/`mailer` (SMTP con AUTH y TLS implícito, firma y verificación
  DKIM rsa-sha256 y ed25519-sha256 compatibles con dkimpy), `formatos`/
  `dataformat` (conversión JSON/YAML/TOML/XML/CSV, JSON Pointer, Patch,
  Merge Patch, JSONPath del RFC 9535 y JSON Schema 2020-12 igual que
  jsonschema), `ligero`/`dapper` (micro-ORM con @parámetros, listas en IN,
  mapeo múltiple y lotes), `ensayo`/`vitest` (describir/prueba, ganchos,
  mocks, espías, reloj falso e instantáneas), `estilos`/`tailwind` (CSS de
  utilidades idéntico a Tailwind v4 en 198 reglas y unión como
  tailwind-merge), `extremo`/`trpc` (protocolo de tRPC v11, probado con
  @trpc/client, y tipos de TypeScript), `sistema`/`sysinfo` (CPU, memoria,
  discos, red, procesos y sensores, igual que psutil) y `vigia`/`notify`
  (inotify en Linux y sondeo en el resto).
- `sqlite`: `db_cada_cols` entrega cada fila como lista de [columna, valor]
  en el orden del SELECT (sirve con columnas repetidas).
- Lote 14 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `clave`/`password` (bcrypt y scrypt propios, más Argon2id y PBKDF2 con
  una sola interfaz), `ajustes`/`config` (TOML 1.0 y YAML 1.2 estrictos,
  idénticos a tomllib y ruamel en 350 archivos reales), `caja`/`cache`
  (cachés LRU/LFU con vencimiento, carga y estadísticas; multimapa,
  bimapa, multiconjunto, tabla, rangos, Bloom y limitador de tasa),
  `grafos`/`graph` (Dijkstra, A*, Bellman-Ford, Floyd-Warshall, Yen, Tarjan,
  Kruskal, Dinic, Hopcroft-Karp, PageRank, intermediación y más, igual que
  NetworkX), `navegacion`/`navmesh` (A*, JPS, mapas de flujo y NavMesh con
  embudo), `fichas`/`tokenizers` (BPE y WordPiece compatibles con
  tokenizer.json de Hugging Face), `algebra`/`linalg` (LU, QR, Cholesky,
  valores propios, SVD, pseudoinversa y exponencial, igual que NumPy) y
  `cuaternion`/`quaternion` (Euler en 24 secuencias, slerp y matrices 4×4,
  igual que SciPy).
- Lote 13 de bibliotecas (con alias en inglés y pruebas en ambos idiomas):
  `grafo_api`/`graphql` (servidor GraphQL con SDL, variables, fragmentos,
  directivas e introspección), `api_rapida`/`fastapi` (rutas tipadas,
  validación 422, dependencias, Bearer y OpenAPI 3.1 con /docs),
  `modelo_db`/`orm` (esquemas, consultas y migraciones para SQLite,
  Postgres y MySQL), `documento`/`pdf` (crear y leer PDF con fuentes
  base-14, imágenes y enlaces), `composicion`/`typeset` (documentos con
  párrafos justificados, tablas, markdown y pie "Página X de Y"),
  `bandeja`/`mailbox` (MIME, IMAP y POP3), `consenso`/`raft` (Raft con
  red simulada) y `buscador`/`fulltext` (BM25, raíces en español e
  inglés, tolerancia a errores, frases y facetas).
- `sqlite`: los nombres de columnas se leen tras el primer paso, así ya no
  quedan viejos después de un `ALTER TABLE`.
- `planilla` y `consulta_archivos`: el separador interno ya no usa el
  texto literal "\u0001".
- `rastreo`/`glob`: recorrer carpetas y buscar con comodines (`**`, `{a,b}`,
  `[a-z]`). El lenguaje suma `listar_carpeta`, `es_carpeta` y `crear_carpeta`
  (como `mkdir -p`).
- **Textos:** una coma fuera de paréntesis dentro de una llave tampoco
  interpola, así los globs (`"*.{cfv,txt}"`) se escriben tal cual.
- **Lote 6 (bilingüe):** `regla`/`validator` (formularios campo a campo,
  RUT chileno), `permisos`/`rbac` (roles con herencia, dominios, denegar y
  condiciones ABAC), `interruptor`/`flags` (feature flags con despliegue
  gradual estable y variantes A/B), `telefono`/`phone` (E.164, móvil/fijo,
  WhatsApp), `indicadores`/`ta` (SMA, EMA, RSI de Wilder, MACD, Bollinger,
  ATR, estocástico), `derivados`/`quant` (Black–Scholes con griegas,
  volatilidad implícita, binomial, bonos, VAN/TIR, amortización),
  `ruido`/`noise` (Perlin, simplex, celular, fractal) y
  `diagnostico`/`diagnostics` (errores con el código subrayado).
- **Lote 7 (bilingüe):** `segundo_factor`/`totp` (TOTP/HOTP con los vectores
  de los RFC 6238 y 4226), `metricas`/`metrics` (formato Prometheus),
  `gramatica`/`parser` (combinadores con precedencia y errores con
  línea/columna), `mosaico`/`tilemap` (Tiled, colisiones, A*),
  `dialogo`/`dialogue` (narrativa con condiciones y variables),
  `geometria`/`geo` (haversine, polígonos, envolvente, GeoJSON),
  `cronometro`/`bench` (benchmarks con estadística) y `paseo`/`paseto`
  (PASETO v4.public, verificado con el vector oficial).
- **`a_numero` y JSON:** aceptan exponentes (`"2.5e1"`) y redondean una sola
  vez, igual que los literales del compilador.
- **Lote 5 (bilingüe):** `indice`/`search` (texto completo con BM25, pesos
  por campo, tildes, plurales, prefijos y exclusiones), `vecindad`/`vectors`
  (k vecinos por coseno, euclídea o punto, con filtros), `numerica`/`numeric`
  (estadística, regresión, FFT, integrales y raíces), `aprende`/`ml`
  (k-medias, k vecinos, regresión lineal y logística, métricas),
  `elenco`/`ecs` (entidades, componentes, sistemas y eventos),
  `pregunta`/`prompt` (preguntas en la terminal con validación),
  `tabla`/`dataframe` (filtrar, agrupar, unir, CSV) y `flex`/`flexbox`
  (diseño Flexbox completo).
- **Lote 4 (bilingüe):** `paquete_bin`/`msgpack` (MessagePack con vectores
  de la especificación y límites contra mensajes hostiles), `css`
  (minificador y analizador), `subida`/`multipart` (formularios con
  archivos, nombres seguros, límites), `cola`/`queue` (trabajos con
  prioridad, retrasos, reintentos y guardado), `calco`/`mapper` (mapeo
  declarativo), `contrato`/`openapi` (OpenAPI 3.1 desde los esquemas),
  `cosecha`/`scrape` (HTML real con selectores CSS) y `matriz`/`ndarray`
  (N dimensiones, difusión, producto matricial).
- **Números decimales:** los literales se redondean una sola vez (antes
  `123.456` o `1e300` podían quedar a 1 ulp); mostrar un subnormal como
  `5e-324` ya no falla, y `bytes_entero` acepta decimales enteros como `2^53`.
- **Textos:** una llave con `:` o `;` dentro no interpola, así CSS
  (`"a{color:red}"`) y objetos de JS (`"{a: 1}"`) se escriben tal cual.
- Las pruebas de bibliotecas se llaman `prueba_*.cfv` para que nunca tapen
  a un módulo al importarlo.
- **Lote 3 (bilingüe):** `esquema`/`schema` (validación con rutas de error y
  mensajes en ambos idiomas), `freno`/`ratelimit` (cubeta de fichas por
  clave, cabeceras RateLimit-*), `casco`/`helmet` (CSP, HSTS, nosniff,
  anti-clickjacking, sin inyección de cabeceras), `idiomas`/`i18n` (claves
  anidadas, plurales, respaldo, números por idioma), `ficticio`/`faker`
  (datos reproducibles, RUT válido, dominios reservados), `xml` (sin
  DOCTYPE/ENTITY: nada de XXE), `reloj`/`cron` (próxima ejecución sin
  recorrer minuto a minuto, desfase horario) y `vitrina`/`rich` (tablas,
  paneles y árboles con anchos Unicode correctos).
- **Textos:** una llave doble `{{` ya no interpola, así las plantillas
  (`"{{nombre}}"`, `"{{#si x}}"`) se escriben sin espacios ni escapes.
- Nuevas funciones del lenguaje: `escribir(v)` (sin salto de línea) y
  `variable_entorno(nombre)`.

## 4.9.0 — 2026-11-21

- **Java dentro de C-Forge** (`importar "java"`, JNI): `java_iniciar`,
  `java_estatico`, `java_nuevo`, `java_metodo`, `java_soltar`; las
  excepciones de Java llegan como errores capturables con su mensaje.
- **C# / .NET dentro de C-Forge** (`importar "dotnet"`, hostfxr):
  `dotnet_iniciar`, `dotnet_funcion` (métodos `[UnmanagedCallersOnly]`),
  `dotnet_llamar` y `dotnet_llamar_texto`.
- **TypeScript:** `cforge bindgen archivo.d.ts --lib paquete` genera las
  declaraciones `extern "npm:…"` (uniones, opcionales, `export default`).
- Interoperabilidad documentada en el README, `capabilities.json` y
  `c-forge.org/llms.txt`; prueba `tests/interop` (Java y C#) en el CI.

- **Paquetes npm** en `--target wasm`: `extern "npm:lodash" funcion
  kebabCase(t: texto): texto` importa el paquete solo (Node.js desde
  `node_modules`; en el navegador, el empaquetador o esm.sh). Funciona con
  paquetes CommonJS y ESM (`como "default"` para la exportación por
  defecto); si falta el paquete, el error dice qué instalar.

## 4.8.0 — 2026-11-21

- **`cforge bindgen cabecera.h [--lib nombre] [-o modulo.cfv]`**: genera un
  módulo C-Forge con las funciones (`extern`), constantes (`#define`
  numéricos y de texto, `enum`) y tipos de una cabecera C, siguiendo los
  `#include "…"` locales y desenvolviendo macros como `ZEXPORT` u
  `OF((…))`. Sirve para C y para Rust, C++ o Zig con interfaz C. Probado con
  zlib (86 funciones) y SQLite (329). Lo que `extern` no puede declarar
  (float de 32 bits, structs por valor, `...`, más de 6 enteros) se omite
  con un comentario. También como biblioteca: `importar "bindgen"`.

## 4.7.0 — 2026-11-21

- **Web sin JavaScript ni CSS aparte** (`importar "navegador"`):
  `nav_evento("tecla" | "id" | "origen" | "destino" | "x" | "y" | "valor")`
  con los datos del evento, `nav_al_tecla("Escape", f)`,
  `nav_al_soltar(origenes, destinos, f)` (arrastrar y soltar con
  delegación, también para elementos creados después) y `nav_css(…)`.
  `cforge build --target wasm --html` genera la página. Ejemplo
  `ejemplos/web/tablero` y prueba en Chromium real en el CI.
- WebAssembly: las funciones de la biblioteca estándar y del runtime ya no
  son raíces (solo las del usuario): módulos algo más chicos.

- **Parámetros `entero` probados:** se comprueban una sola vez al entrar a
  la función (error de tipos claro y capturable si llega otra cosa) y, si el
  cuerpo solo les reasigna enteros, sus operaciones y comparaciones se
  emiten sin volver a comprobarlos. Las variables `sea x: entero = …` también
  quedan probadas. Primos con tipos (`benchmarks/08_primos_tipados.cfv`):
  ~43 → ~35 ms con `--release`.
- Corregido: los tipos de los parámetros de cierres y métodos se alineaban
  con el nombre oculto (la función o `esto`) en vez del parámetro.

## 4.6.0 — 2026-11-19

- **`Ok(v)` / `Error(e)` y `Alguno(v)` / `Ninguno`** de primera clase,
  integrados con `?`, y **`coincidir`** (`match`): expresión con patrones de
  variante, de valor y `_`.
- **`async funcion` / `await`** (también `asincrona` / `aguardar`) sobre las
  tareas con hilos nativos; los errores se relanzan en el `await`.
- **Versionado semántico en paquetes:** `@^1.2.0` y `@~1.2.0` eligen el tag
  más alto que cumple; `cforge.lock` guarda commit, SHA-256 del árbol y tag,
  y compilar verifica la integridad.
- **`cforge test --coverage`** (cobertura de líneas, también si una prueba
  falla) y **`cforge doc`** (Markdown o HTML desde los comentarios `///`).

- **Seguridad:** todas las reservas de píxeles y audio (PNG, JPEG, BMP,
  lienzos, z-buffer, PCM) pasan por `md_buffer_seguro` con aritmética
  saturada. `cforge add` rechaza antes de separar la especificación
  cualquier carácter fuera de `[A-Za-z0-9._/-]` y una `@` (secuencias
  `%2e`/`%2f`/`%5c`, `\u002e`, barras invertidas, bytes nulos) y valida el
  alias de `--como`. Vectores nuevos en `tests/seguridad`.

## 4.5.0 — 2026-11-19

- **Seguridad:** endurecimiento contra entradas hostiles tras una auditoría
  ofensiva (detalle en `SECURITY.md`): `cforge add` sin path traversal,
  límites de imágenes y de descompresión, servidor HTTP con límites,
  timeouts y rechazo de smuggling, WebSocket con límites y validación RFC
  6455, TLS 1.2+ con suites AEAD, borrado de secretos con barrera de memoria,
  tope de anidamiento en el parser y JPEG progresivo con bandas validadas.
- **`byte_en`** fuera de rango ahora es un error capturable.
- **`zlib_descomprimir`, `gzip_descomprimir` e `inflar`** aceptan un límite
  de salida; **`servidor_http_limites`** y **`ws_limites`** configuran los
  del servidor.
- Pruebas `tests/seguridad` (las tres plataformas) y `ataques.py` (CI).
- **TLS 1.3 en Windows:** Schannel con `SCH_CREDENTIALS` (TLS 1.3 y 1.2,
  cifrados AEAD, SSL 2/3 y TLS 1.0/1.1 desactivados), respaldo automático a
  `SCHANNEL_CRED` en Windows anteriores a 1809 y mensajes de sesión de TLS
  1.3 con el host real. Nueva **`tls_version(t)`**; el CI de Windows exige
  `TLSv1.3`.
- **`--release` más rápido** (benchmark de enteros: 73 → ~45 ms; listas y
  mapas ×2): plegado de constantes, reducción de fuerza (× / % por potencias
  de 2 → desplazamientos y máscaras en x64, ARM64 y WASM), comparación y
  salto fusionados, mirilla que quita cargas tras un guardado, marco
  principal sin celdas cuando no hay cierres, asignador con máscara de
  listas libres y concatenación de enteros sin texto intermedio.
- **GC:** corregida una corrupción latente — con una arena de 64 MiB llena,
  limpiar su mapa de marcas pisaba un byte de la arena vecina. Prueba de
  regresión `tests/memoria/arena_llena.cfv`.
- **Búferes:** `ws_recibir` reutiliza un búfer por conexión, desenmascara en
  el sitio (de a 8 bytes) y no copia los mensajes de una sola trama
  (`bytes_bufer`, `net_recibir_en`, `bytes_desenmascarar`); `db_insertar` y
  `db_actualizar` reutilizan el SQL validado (20 000 inserciones: 490 → 293
  ms); `motor_textura` cachea por ruta (`motor_textura_olvidar`) y las
  cachés de juego tienen tope; inflar copia de a 8 bytes (×2) y deflate
  compara coincidencias de a 8 bytes; validación temprana de índices WASM
  (< 2^32).
- **`CFORGE_MAPA=archivo`** escribe el mapa de símbolos del ejecutable ELF
  (para perfiladores).

## 4.4.0 — 2026-11-18

- **Criptografía estable:** ChaCha20-Poly1305, XChaCha20, AES-256-GCM,
  X25519, Ed25519, BLAKE2b, BLAKE3, Argon2id, SHA-384/512, HKDF y RSA-OAEP en
  C-Forge puro, con vectores oficiales en CI; API sin nonces manuales,
  contraseñas PHC y JWT con `exp`.
- **Bases de datos estables:** SQLite con caché de sentencias, `?N` y
  `:nombre`, BLOB, transacciones anidadas, pool e identificadores validados;
  MySQL 8 con `caching_sha2_password` completo (RSA).
- **Gráficos y juegos estables:** `imagen` (PNG, JPEG, BMP, zlib), `graficos`
  (2D con antialiasing y 3D por software), `fuente` (TrueType), `modelo`
  (OBJ y primitivas), física 2D/3D de verdad, audio con mezclador y salida
  SDL2, OpenGL con texturas. Igual bit a bit en todas las plataformas.
- **WebAssembly estable:** más rápido (saltos directos y paso al código
  optimizado de V8), validación de cada `.wasm` en CI, `nav_mostrar_lienzo` y
  ejemplo `ejemplos/web/cubo3d`.
- **Lenguaje:** `m["k"] ?? defecto` ya no falla con claves ausentes;
  `__ccall`/`c_llamar` admiten hasta 10 argumentos (también en ARM64);
  JSON guarda los números con 15 cifras.

## 4.3.0 — 2026-11-18

- **WebAssembly (`cforge build --target wasm`):** nuevo backend
  `gen_wasm.cfv` sobre la misma capa `gen.cfv`. Genera `app.wasm`, el
  cargador `app.mjs` (navegador y Node.js) y `app.d.ts`. 28 de las 29 suites
  del lenguaje pasan en Node.js (la otra usa librerías C).
- **`extern "js"`** y llamadas de JavaScript a funciones de C-Forge
  (`cf.llamar("nombre", n)`).
- **`stdlib/navegador.cfv`:** DOM, eventos, animación, lienzo 2D y partículas
  WebGL2. Ejemplo: `ejemplos/web/particulas`.
- **c-forge.org:** la física de las partículas del sitio está escrita en
  C-Forge (`site/forja/forja.cfv`) y corre en WebAssembly.
- **`cociente(a, b)`** (división entera) y **`bits_y`, `bits_o`, `bits_xo`**,
  en línea entre enteros; `lista[i]` y `lista[i] = v` en línea.
- **`lista_direccion(l)`** para compartir los elementos de una lista sin
  copiarlos.

## 4.2.0 — 2026-11-18

- **`cforge repl`:** consola interactiva con estado (variables, funciones de
  varias líneas, `:programa`, `:limpiar`); una expresión suelta muestra su
  valor y los errores no cortan la sesión.
- **Interpolación estricta:** `{` interpola solo si la sigue una letra, `_` o
  `(` y cierra en la línea; JSON y GLSL ya no necesitan `\{`.
- **Notación científica:** `1e5`, `2.5e-3`, `6.02E+23`.
- **Recolector de basura:** marcado y barrido conservador sobre el asignador
  propio (raíces: globales, variables de nivel superior y pila del
  lenguaje), con bloques reciclados en cero y división de bloques libres.
  2 M iteraciones creando textos: de 1,7 GB a 9 MB de pico; un servidor HTTP
  con 10 000 solicitudes: de 231 MB a 8,6 MB. `memoria_estadisticas()`,
  `CFORGE_GC=0` (desactivar) y `CFORGE_GC_ESTRES=1` (pruebas). No recolecta
  mientras haya hilos de `tarea()` vivos.
- **Verificador de tipos estáticos:** `cforge check`, `build` y el LSP
  detectan antes de ejecutar los errores de tipo con anotaciones (`sea x:
  numero`, parámetros y retorno) e inferencia local (`sea n = 5`, si la
  variable no se vuelve a asignar): asignaciones, argumentos, valores de
  retorno, operadores (`texto - numero`, comparar lista con número),
  condiciones y `no` que no son booleanas. Lo que no se conoce sigue siendo
  dinámico (tipado gradual): ningún programa válido deja de compilar.
- **Velocidad:** `+ - * %` y comparaciones de enteros en línea (sin llamar
  al runtime), enteros probados por el verificador sin comprobar etiquetas y
  condiciones booleanas de una instrucción. Primos hasta 200 000 + fib(30):
  de 460 ms a 73 ms (Java 21: 67 ms, gcc -O2: 25 ms).
- **`cforge build --release`:** elimina las funciones que el programa no usa
  (dos pasadas). "hola": de 231 KB a 34 KB en Linux.
- **Punteros seguros:** `*T` nunca es nulo y `?T` / `?*T` se comprueba antes
  de usarse (`si (q) |nodo| { … }` o `si (q != nulo)`); los errores salen en
  `cforge check`, `build` y el LSP.
- **`comptime`:** `comptime(expr)` y `comptime { … }` se ejecutan al compilar
  y quedan como literales; genéricos `comptime T` verificados por llamada.
- **WebSocket real (RFC 6455)** en `stdlib/red.cfv`: cliente (`ws_conectar`,
  `ws_conectar_url`) y servidor (`ws_aceptar` sobre `servidor_http_*`),
  texto, binario, fragmentación, ping/pong y cierre con código. Reemplaza el
  atajo por UDP.
- **PostgreSQL nativo** (`stdlib/postgres.cfv`): protocolo v3 sin libpq,
  SCRAM-SHA-256 (con verificación de la firma del servidor), MD5, consultas
  con parámetros por el protocolo extendido y tipos convertidos.
- **MySQL / MariaDB nativo** (`stdlib/mysql.cfv`): protocolo 4.1,
  mysql_native_password y caching_sha2_password (autenticación rápida),
  parámetros `?` escapados. La autenticación completa de caching_sha2 sin TLS
  (RSA) no está soportada.
- **Runtime:** `cfv_sha1`, `sha1_bytes`, `sha256_bytes`, `hmac_sha256_bytes`,
  `pbkdf2_sha256`, `bytes_entero`, `bytes_leer_entero`, `bytes_xor`,
  `bytes_buscar`, `bytes_de_hex`, `hex_de_bytes`, `net_recibir_exacto`,
  `servidor_http_tomar_conexion`.
- **`docs/GLOBALES.md`:** mapa de las casillas globales del runtime. Corrige
  dos choques de 4.1: las tablas de AES usaban la caché de `argv` en Windows
  (ahora casilla 15) y el handle de libssl la casilla de `sys_casilla` (16).

## 4.1.0 — 2026-11-18

- **Biblioteca estándar completa en C-Forge:** los 35 módulos de `stdlib/`
  cargan con el compilador nativo; `stdlib/PENDIENTES` desaparece.
- **Red:** cliente HTTP/1.1 (`http_solicitud`, chunked, redirecciones,
  cabeceras en un mapa), TCP (`net_*`), UDP (`udp_*`) y DNS propio en Linux
  (`/etc/hosts` y consulta A por UDP); `getaddrinfo` en macOS y Windows.
- **HTTPS:** `stdlib/tls.cfv` con OpenSSL 3/1.1 (Linux, macOS con
  `openssl@3`) y Schannel (Windows), verificando certificados y nombre.
- **SQLite:** `stdlib/sqlite.cfv` y `db.cfv` sobre la biblioteca del sistema
  (`libsqlite3`, `/usr/lib/libsqlite3.dylib`, `winsqlite3.dll`).
- **OpenGL 3.3 core:** `runtime/gl3d.cfv` (shaders, VBO, uniformes,
  profundidad, `glReadPixels`) y `gl_ventana`; matrices con trigonometría real.
- **Cripto:** `hmac_sha256`, AES-256-CBC compatible con OpenSSL y
  `crypto_rand_bytes` con el generador del sistema.
- **Lenguaje y runtime:** `lista + lista`, `__ccall` con la ABI de Windows y
  hasta 8 argumentos, `c_llamar`, `c_f32`, `c_cadena`, `c_leer64`; nombres de
  3.x que faltaban (`subarray`, `separar`, `unir`, `texto_subcadena`, …).
- Correcciones en módulos que estaban rotos en 3.x: `redis` (respuestas con
  CRLF), `auth` (OAuth con `http_solicitud`), `db_actualizar`/`db_eliminar`
  devuelven filas afectadas, el ejemplo de `gl`.

## 4.0.0 — 2026-11-18

- **100 % C-Forge: se retiró el C++.** El intérprete `cforgev.cpp`
  (`cforge-clasico`), el Stage 0 en C++20, `include/` y la cadena de
  arranque antigua (compilador Core, backends `bootstrap/direct`) salen del
  repositorio. La semilla `bootstrap/semilla/cforge-linux-x64` compila
  `cforge` (Stage 2 = Stage 3); Makefile, CI, release, Docker, `.deb`,
  Homebrew e instaladores usan solo C-Forge. Releases nuevas: Linux ARM64
  (`.tar.gz` y `.deb`) y macOS Intel.
- `cforge test`, `cforge new` (alias de `init`), `cforge doctor`,
  `paralelo(f, lista)`, `tiempo_actual()` y los
  alias `file_write` / `file_read`.
- **Pendiente para 4.1:** 14 módulos de la stdlib que usaban funciones del
  intérprete C++ (`stdlib/PENDIENTES`: cripto, bases de datos, cliente
  HTTP/TLS, WebSocket, UDP, OpenGL, audio…), un recolector de basura para
  cadenas temporales y `cforge repl`.

- **Backend nativo ELF sin libc** (`bootstrap/nativo/`): código máquina x86-64
  directo con marcos de pila y recursión; ejecutables estáticos de pocos KB.
- **Runtime 100 % C-Forge** (`runtime/`): syscalls de Linux aisladas en
  `sys_linux.cfv`, asignador propio sobre `mmap` con listas libres, textos y
  listas dinámicas, archivos y formato de decimales.
- **Primer hito de autoalojamiento**: el lexer de C-Forge escrito en el
  dialecto nativo produce los mismos tokens que el lexer Core.
- `make nativo-check` y job de CI "Backend nativo (Linux, sin libc)".
- **Compilador autoalojado** (`bootstrap/nativo/cforge_self.cfv`): compilador
  de una pasada escrito en el dialecto nativo que se compila a sí mismo.
  Stage 2 = Stage 3 byte por byte, sin libc ni C++ (`make autoalojado-check`).
- **Listas y mapas nativos** en el compilador autoalojado: valores dinámicos
  etiquetados, `runtime/map.cfv` (tabla hash) y `runtime/dyn.cfv`. Las pruebas
  de colecciones de la suite pasan compiladas a ELF sin libc.
- **Clases nativas** en el compilador autoalojado: clases, estructuras,
  herencia, `super`, interfaces, despacho dinámico de métodos, palabras clave
  en inglés y errores con `archivo.cfv:línea`.
- **Funciones anónimas y errores nativos**: cierres con captura por
  referencia, globales, `intentar`/`capturar`/`finalmente`/`lanzar`, `??`.
  15 de 25 pruebas de la suite compiladas a ELF sin libc.
- **Biblioteca estándar nativa** (`runtime/biblioteca.cfv`, JSON y regex en
  `runtime/lenguaje.cfv`), interpolación de textos y `si(c, a, b)`:
  24 de 25 pruebas de la suite compiladas a ELF sin libc.
- **`extern` nativo**: `cforge_self` genera ELF dinámicos por sí mismo
  (PT_INTERP, PT_DYNAMIC, GOT, ABI System V). **25 de 25 pruebas de la suite
  compiladas por el compilador autoalojado.**
- **`cforge` 100 % C-Forge en Linux**: CLI nativo (`run`, `build`, `check`)
  con runtime incrustado, semilla de arranque sin C++ verificada en CI, y
  releases/instalador que distribuyen el compilador nativo como `cforge`
  (con `cforge-clasico` para lo que aún no es nativo).
- **22/22 `ejemplos/` con el compilador nativo**: `extern` genérico con
  `dlopen` (SDL2, sqlite3, cualquier `.so`), hilos reales con `clone` y
  `futex`, canales y mutex, servidor HTTP con sockets, SDL2 en C-Forge,
  `?.`, ternario, `expr?`, genéricos, valores por defecto, variádicos,
  `inseguro` con punteros verificados y atributos `#[...]`.
- **Windows x86-64 100 % C-Forge**: backend PE64 con IAT, ABI x64 de
  Windows, `runtime/sys_windows*.cfv`, hilos con `CreateThread`, Winsock y
  `extern` con `LoadLibrary`. En Windows real: Stage 2 = Stage 3 = compilación
  cruzada desde Linux; 25/25, 32/32 y 22/22.

## 3.7.3 — extern C + idioma del programa

- **FFI con C**: `extern "libreria" funcion nombre(p: tipo): tipo` carga la
  librería (dlopen / LoadLibrary) y llama con la ABI de C de la plataforma.
  Tipos: entero, largo, numero, texto, puntero, booleano, vacio (y sus nombres
  en inglés). `"libc"` y `"libm"` se resuelven solos. Hasta 8 parámetros, sin
  variádicas. Prueba `24_extern_c.cfv`.
- **Idioma del programa**: si predominan las palabras clave en inglés, los
  booleanos/nulo se muestran como true/false/null y los errores comunes en
  inglés. Prueba `25_idioma_ingles.cfv`.
- **docs/SPEC.md**: especificación oficial con estado real de cada pieza.
- Ejemplos de `extern` en c-forge.org (Aprende / Learn).

## 3.7.2 — sintaxis bilingüe + nuevo c-forge.org

- **Sintaxis bilingüe**: las palabras clave en inglés (`let`, `function`,
  `return`, `if`, `else`, `while`, `for`, `in`, `try`, `catch`, `throw`,
  `class`, `this`, `import`, `break`, `continue`, `and`, `or`, `not`, `true`,
  `false`, `null`, `print`, `assert`) son alias exactos del español y se pueden
  mezclar en un mismo archivo. Tras un `.` no se traducen.
- **Funciones integradas en inglés**: `length`, `append`, `sort`, `upper`,
  `lower`, `replace`, `to_text`, `to_number`, `json_parse`, `json_stringify`,
  `json_pretty`, `json_valid`. Si el programa define una función o variable con
  ese nombre, se usa la suya.
- **c-forge.org rehecho**: sin inicio de sesión ni panel; páginas Inicio y
  Aprende generadas desde el repo. Ejemplos, versión, estado y novedades salen
  de fuentes verificables y `site/verificar.sh` los comprueba en CI.
- **Corrección**: una función definida por el programa ya no queda tapada por
  una integrada con el mismo nombre (p. ej. `dividir`, `contiene`).
- `capabilities.json`: multiplataforma pasa a estable (CI verde en Linux,
  macOS y Windows).

## 3.7.1 — instalación en un comando + Windows estable

- **install.sh único** (repo y c-forge.org): descarga el binario de GitHub
  Releases, verifica SHA-256 y compila desde fuente si no hay binario para la
  plataforma. Instala en `~/.local` si no hay `sudo`.
- **install.ps1** nuevo para Windows: `irm https://c-forge.org/install.ps1 | iex`.
- **Stdlib automática**: `cforge` busca la stdlib junto al ejecutable; ya no se
  necesita `CFORGE_STDLIB`.
- **Windows**: el fallo de la suite con MSVC era la pila de 1 MB; se enlaza con
  64 MB y la suite completa vuelve a ser obligatoria en CI y release.
- **macOS x86-64 nativo (Mach-O)**: `--target macos`, escritor Mach-O propio
  enlazado a `libSystem.B.dylib`, `runtime/sys_macos*.cfv` y CI en macOS real
  (Stage 2 = Stage 3 = compilación cruzada; 25/25, 32/32, 22/22).
- **Capa intermedia del generador** (`gen.cfv`, `gen_x64.cfv`, `gen_a64.cfv`)
  y **backend AArch64**: `--target macos-arm64` (Mach-O PIE con firma ad-hoc
  SHA-256 propia) y `--target linux-arm64`. Apple Silicon: Stage 2 = Stage 3
  = compilación cruzada desde Linux y Windows; 25/25, 32/32, 22/22.
- **Gestor de paquetes**: `cforge init`, `cforge add usuario/repo[@ref]`,
  `cforge remove`, `cforge install`, `cforge.toml` y `cforge.lock`; caché
  global de descargas de GitHub e `importar "alias"` / `"alias/modulo"`.
- **`cforge fmt`** (formateador idempotente que conserva los tokens) y
  **`cforge lsp`** (diagnósticos, autocompletado, definición, información y
  formateo), con la extensión de VS Code como cliente del servidor (`.vsix`).
- **Apple**: `cforge build --lib` (`.a` + `.h` de las funciones `#[Exportar]`),
  `--target ios-arm64` / `ios-sim-arm64`, `cforge xcode-init` (regla de
  Xcode, cabecera puente para Swift, `CForge.xclangspec`) y `stdlib/apple.cfv`
  (puente con Objective-C).
- **CI**: smoke test con rutas absolutas; se elimina `build-native.yml`
  (duplicado).
- **Web**: c-forge.org vive en `site/` y se despliega en Cloudflare Pages; se
  quitan comandos de brew/winget/scoop que no existían.
- Repositorio oficial: `VemorisSoftware/C-Forge`.

## 3.7.0 — CLI completo + versión centralizada + SDL2 estable + release automatizado

- **Versión centralizada**: Makefile es la única fuente de verdad para VERSION.
  `cfv_version()` lee la constante compilada; `--version` y el REPL son siempre
  coherentes. Procedimiento de bump documentado en Makefile.
- **CLI completo**: añadidos `cforge new <nombre>`, `cforge init` y `cforge doctor`.
  - `new` crea directorio, `main.cfv` y `cforge.json` en un solo paso.
  - `init` genera `cforge.json` en el directorio actual sin sobrescribir archivos.
  - `doctor` diagnostica versión, CFORGE_STDLIB, compilador C++ disponible,
    OpenSSL y SQLite.
- **SDL2 estable**: corregido "índice de lista inválido" en `sdl_eventos()` causado
  por el despacho del API antiguo que intentaba leer argumentos vacíos.
  Todos los eventos pasan ahora por el despacho dlopen unificado.
  `sdl_quiere_salir` y el bucle de evento de trafico_visual.cfv usan try/catch
  para claves ausentes en eventos de teclado.
- **release.yml**: artefactos versionados (`cforge-3.7.0-linux-x64.tar.gz`, etc.),
  validación de que el tag coincide con Makefile VERSION, generación de
  `release-manifest.json` para c-forge.org.
- **install.sh**: auto-detecta la versión más reciente desde la GitHub Releases API;
  fallback a 3.7.0 si la red no está disponible. Añadidos `new`, `init` y `doctor`
  al texto de ayuda post-instalación.
- **capabilities.json**: actualizado a 3.7.0; scope de `native-cli` refleja los
  comandos reales implementados.
- **Extensión VS Code 3.7.0**: CHANGELOG reescrito con información real; eliminadas
  referencias a puentes Java/Python/JS que no existen en esta versión.
- Herramientas de tipo y compilación escritas en C-Forge (`cftype.cfv`, `cfpkg.cfv`);
  los archivos Python anteriores (`cftype.py`, `cf2c.py`) no forman parte del
  repositorio — toda la toolchain es autónoma.

## 3.2.0 — dominio oficial + concurrencia real + compilación nativa

- Dominio oficial adquirido: **c-forge.org**
- Concurrencia real con `std::thread`: `hilo_crear`, `hilo_esperar`, `hilo_id`, `hilo_activo`.
- Mutex reales: `mutex_crear`, `mutex_bloquear`, `mutex_desbloquear`, `mutex_intentar`.
- Canales thread-safe integrados con el sistema de hilos.
- Soporte Unicode avanzado: bytes ≥ 0x80 aceptados en identificadores.
- Herramientas de tipo e introspección implementadas en `.cfv`.
- LSP básico funcional en la extensión VS Code.
- BDD testing stdlib (`describir/cuando/entonces`).
- Backends directos (Mach-O ARM64, ELF x64, PE x64) en estado parcial.

## 2.6.0 — primer núcleo estable

- Eliminados de las dos fuentes C++ los puentes heredados de Python, Java/JNI y
  JavaScript.
- Motor y CLI unificados bajo el ejecutable `cforge`.
- Biblioteca activa reducida a 31 módulos `.cfv` que pasan sintaxis y carga.
- Suite nativa ampliada a 15 archivos `.cfv`.
- Parser JSON endurecido frente a entradas truncadas, tokens inválidos y datos
  sobrantes.
- Construcción oficial reducida de 292 avisos a cero en el entorno local.
- Gate reproducible para build, sintaxis, carga real de 31 módulos, pruebas,
  CLI, entradas dañadas, ASan/UBSan, emisores directos e instalación aislada.
- Empaquetado Homebrew y Debian migrado al motor nativo, sin Python.
- Flujos de CI y release renovados para compilar el motor nativo en macOS,
  Linux y Windows.
- Backends directos reclasificados correctamente como prototipos limitados a
  `mostrar("texto")`.
- Artefactos históricos, caches y módulos incompletos retirados del árbol
  activo de forma recuperable.
- Runtime, CLI, JSON y núcleo de biblioteca declarados estables; red, bases de
  datos, criptografía, gráficos, backends completos y autoalojamiento conservan
  explícitamente sus estados experimental, parcial o planeado.

Las versiones anteriores mezclaban prototipos y afirmaciones no respaldadas.
Su historial permanece disponible en Git, pero no define las capacidades del
producto actual. La fuente de verdad es `capabilities.json`.
