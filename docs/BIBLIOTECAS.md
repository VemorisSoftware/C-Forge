# Ecosistema de bibliotecas de C-Forge (251)

Nombres propios de C-Forge para las 251 áreas del catálogo. Cada una se
implementa en su propio PR, en `.cfv`, con pruebas y verificada en el CI;
la columna «Inspiración» sirve para revisar la licencia antes de portar
(MIT, BSD, Apache, zlib: sí, conservando el aviso; GPL/LGPL: solo vía
`bindgen`, sin copiar código).

Estado: ✅ ya existe en C-Forge · 🔗 se usa hoy vía `cforge bindgen`,
`extern "npm:…"`, `importar "java"` o `importar "dotnet"` · 🛠 por construir.

## Bloque 1 — Base

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 1 | `compacta` | Compresión rápida | zlib, zstd | ✅ zlib nativo · 🛠 zstd |
| 2 | `bodega` | SQL embebido en un archivo | SQLite | ✅ `sqlite` / `db` |
| 3 | `rayo_json` | JSON ultrarrápido | cJSON, simdjson | ✅ `json` · 🛠 SIMD |
| 4 | `ventana` | Ventanas, audio y entrada | SDL2, Raylib | ✅ `juego` / `sdl` |
| 5 | `panel` | GUI de modo inmediato | Dear ImGui | 🛠 |
| 6 | `latido` | Bucle de eventos asíncrono | libuv | 🛠 |
| 7 | `boveda` | Criptografía moderna | OpenSSL, libsodium | ✅ `crypto` / `tls` |
| 8 | `pixel` | Imágenes y tipografías | stb_image, stb_truetype | ✅ `imagen` / `fuente` |
| 9 | `inercia` | Física 2D y 3D | Box2D, Bullet | ✅ `fisica2d` / `fisica3d` (básica) |
| 10 | `fotograma` | Audio y video | FFmpeg | ✅ audio PCM/WAV · 🔗 video |
| 11 | `marea` | Runtime asíncrono para servidores | Tokio | 🛠 |
| 12 | `molde` | Serialización universal | Serde | 🛠 |
| 13 | `enjambre` | Paralelismo de datos | Rayon | 🛠 |
| 14 | `orden` | Argumentos de línea de comandos | Clap | 🛠 |
| 15 | `mensajero` | Cliente HTTP | Reqwest | ✅ `red` |
| 16 | `portico` | Framework web | Axum, Actix | ✅ `web` (básico) |
| 17 | `tabla` | DataFrames | Polars | 🛠 |
| 18 | `elenco` | Entidad-Componente-Sistema | Bevy ECS | 🛠 |
| 19 | `blindaje` | TLS y cripto puras | Ring, Rustls | ✅ `crypto` · 🛠 TLS propio |
| 20 | `patron` | Expresiones regulares sin ReDoS | regex (Rust) | ✅ `regex` |
| 21 | `consulta` | Consultas perezosas sobre colecciones | LINQ | ✅ `colecciones` (parcial) |
| 22 | `ligero` | Micro-ORM | Dapper | 🛠 |
| 23 | `mapeador` | ORM con migraciones | EF Core | ✅ `db` (migraciones) · 🛠 ORM |
| 24 | `senal` | Tiempo real con reconexión | SignalR | 🛠 |
| 25 | `arbol_json` | JSON tipado y dinámico | System.Text.Json | ✅ `json` |
| 26 | `regla` | Validación encadenada | FluentValidation | 🛠 |
| 27 | `calco` | Mapeo entre estructuras | AutoMapper | 🛠 |
| 28 | `resiste` | Reintentos y circuit breaker | Polly | 🛠 |
| 29 | `bitacora` | Logs estructurados | Serilog | 🛠 |
| 30 | `torrente` | Red asíncrona de alto tráfico | Netty | 🛠 |
| 31 | `caja` | Colecciones avanzadas y cachés | Guava | ✅ `colecciones` · 🛠 cachés |
| 32 | `formatos` | JSON, XML, CSV y YAML | Jackson | ✅ JSON · 🛠 resto |
| 33 | `registro` | Registro de eventos desacoplado | SLF4J, Logback | 🛠 |
| 34 | `reloj` | Tareas programadas (cron) | Quartz | 🛠 |
| 35 | `indice` | Búsqueda de texto completo | Lucene | 🛠 |
| 36 | `prueba` | Pruebas y aserciones | JUnit | ✅ `cforge test` + `afirmar` |
| 37 | `esquema` | Validación de esquemas | Zod | 🛠 |
| 38 | `ruta` | Framework web con middlewares | Express, Hono | ✅ `web` (básico) |
| 39 | `navaja` | Utilidades funcionales | Lodash | ✅ `lista` / `algoritmos` · 🔗 npm |
| 40 | `calendario` | Fechas y zonas horarias | Day.js, Luxon | ✅ `fecha` |
| 41 | `cartero` | Cliente HTTP con interceptores | Axios | ✅ `red` · 🛠 interceptores |
| 42 | `eco` | Eventos en tiempo real | Socket.io | ✅ WebSocket en `red` |
| 43 | `modelo_db` | Esquemas y consultas limpias | Prisma, Drizzle | 🛠 |
| 44 | `escena` | 3D sobre WebGL | Three.js | ✅ `gl` / `modelo` (básico) |
| 45 | `cosecha` | HTML con selectores CSS | Cheerio | 🛠 |
| 46 | `tinta` | Colores en la terminal | Chalk | 🛠 |
| 47 | `matriz` | Arreglos multidimensionales | NumPy | 🛠 |
| 48 | `planilla` | Análisis de datos tabulares | Pandas | 🛠 |
| 49 | `api_rapida` | APIs con documentación automática | FastAPI | 🛠 |
| 50 | `vitrina` | Interfaces ricas en terminal | Rich | 🛠 |
| 51 | `gradiente` | Tensores con autodiferenciación | PyTorch | 🛠 |

## Bloque 2 — Áreas

### A. Inteligencia artificial y matemáticas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 52 | `oraculo` | LLM locales cuantizados | llama.cpp | 🔗 |
| 53 | `cerebro` | Ejecutar modelos entrenados | ONNX Runtime | 🔗 |
| 54 | `algebra` | Álgebra lineal | Eigen | ✅ `matematica` (básica) · 🛠 |
| 55 | `vision` | Visión por computadora | OpenCV | 🔗 |
| 56 | `vela` | Machine learning ligero | Candle | 🛠 |
| 57 | `fichas` | Tokenización (BPE, WordPiece) | Tokenizers | ✅ `nlp` (básico) · 🛠 |
| 58 | `vecindad` | Búsqueda vectorial | FAISS | 🛠 |
| 59 | `aprende` | ML clásico | scikit-learn | 🛠 |
| 60 | `lector` | OCR | Tesseract | 🔗 |
| 61 | `oido` | Voz a texto | Whisper.cpp | 🔗 |
| 62 | `prediccion` | Entrenar y predecir | ML.NET | 🔗 `dotnet` |
| 63 | `numerica` | Estadística y FFT | Math.NET | 🛠 |
| 64 | `simbolo` | Matemáticas simbólicas | SymPy | 🛠 |
| 65 | `estadistica` | Algoritmos estadísticos | linfa | 🛠 |
| 66 | `hibrida` | Búsqueda vectorial + texto | Qdrant, Tantivy | 🛠 |

### B. Interfaces gráficas y diseño

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 67 | `lienzo` | Motor gráfico 2D | Skia | ✅ `graficos` |
| 68 | `flex` | Layout Flexbox | Yoga | 🛠 |
| 69 | `escritorio` | GUI de escritorio con estilos | Avalonia | 🛠 |
| 70 | `cristal` | Apps de escritorio con WebView | Tauri | 🛠 |
| 71 | `nativa` | GUI reactiva nativa | Iced, egui | 🛠 |
| 72 | `vector` | Gráficos vectoriales a PDF/SVG/PNG | Cairo | ✅ PNG · 🛠 PDF/SVG |
| 73 | `grafia` | Moldeado de tipografías | HarfBuzz | 🛠 |
| 74 | `importa3d` | Modelos 3D (OBJ, glTF) | Assimp | ✅ `modelo` (OBJ) · 🛠 |
| 75 | `gpu` | Vulkan, Metal y DirectX | bgfx, wgpu | 🛠 |
| 76 | `pizarra` | Objetos interactivos en lienzo | Fabric.js | 🛠 |
| 77 | `animacion` | Animaciones vectoriales | Lottie | 🛠 |
| 78 | `estilos` | Utilidades de estilo y temas | Tailwind | 🛠 |
| 79 | `retoque` | Procesamiento de imágenes | ImageSharp | ✅ `imagen` (básico) |
| 80 | `trazo` | Vectores en GPU | Vello | 🛠 |
| 81 | `mini_gui` | GUI embebible mínima | Nuklear | 🛠 |

### C. Redes, seguridad y sistemas distribuidos

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 82 | `llamada` | RPC binario | gRPC, Protobuf | 🛠 |
| 83 | `veloz` | QUIC y HTTP/3 | Quinn | 🛠 |
| 84 | `buzon` | Mensajería entre procesos | ZeroMQ | 🛠 |
| 85 | `malla` | Redes P2P | libp2p | 🛠 |
| 86 | `tunel` | VPN criptográfica | WireGuard | 🛠 |
| 87 | `certifica` | Certificados HTTPS automáticos | ACME | 🛠 |
| 88 | `ficha` | Tokens JWT/JWE | jose | ✅ `auth` (JWT) |
| 89 | `clave` | Hash de contraseñas | Argon2, bcrypt | ✅ `crypto` (PBKDF2) · 🛠 Argon2 |
| 90 | `sonda` | Captura de paquetes | libpcap | 🔗 |
| 91 | `consenso` | Consenso distribuido | Raft | 🛠 |
| 92 | `sensor` | Mensajería IoT | MQTT | 🛠 |
| 93 | `directo` | Audio/video P2P | WebRTC | 🛠 |
| 94 | `transporte` | Transferencia multiprotocolo | libcurl | ✅ HTTP en `red` · 🔗 |
| 95 | `freno` | Límite de peticiones | Governor | 🛠 |
| 96 | `consola_remota` | SSH y SFTP | libssh2 | 🔗 |

### D. Bases de datos y formatos

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 97 | `archivo_kv` | Clave-valor en disco | RocksDB | 🛠 |
| 98 | `analitica` | SQL analítico embebido | DuckDB | 🔗 |
| 99 | `cofre` | Base embebida ACID | sled, redb | 🛠 |
| 100 | `paquete_bin` | Serialización binaria compacta | MessagePack | 🛠 |
| 101 | `sin_copia` | Serialización zero-copy | FlatBuffers | 🛠 |
| 102 | `columnas` | Formato columnar | Arrow, Parquet | 🛠 |
| 103 | `hoja` | Hojas de cálculo .xlsx | libxlsxwriter | 🛠 |
| 104 | `documento` | PDF: crear, leer y firmar | PDFium, lopdf | 🛠 |
| 105 | `archivador` | ZIP/TAR seguros | libarchive | 🛠 |
| 106 | `ajustes` | TOML y YAML estrictos | toml, yaml-rust | ✅ TOML (cforge.toml) · 🛠 |
| 107 | `marcado` | Markdown a HTML | pulldown-cmark | 🛠 |
| 108 | `sintaxis` | Parser incremental | tree-sitter | 🔗 |
| 109 | `xml` | XML rápido | quick-xml | 🛠 |
| 110 | `csv` | CSV gigantes (RFC 4180) | csv-rs | 🛠 |
| 111 | `memoria_rapida` | Cliente Redis con clústeres | fred | ✅ `redis` · 🛠 clústeres |

### E. Web, frontend, APIs y pruebas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 112 | `grafo_api` | Servidor GraphQL | async-graphql | 🛠 |
| 113 | `plantilla` | Plantillas HTML | Tera, Handlebars | 🛠 |
| 114 | `piloto` | Navegadores automatizados | Playwright | 🛠 |
| 115 | `atributo` | Interactividad por atributos HTML | htmx | 🛠 |
| 116 | `css` | Parser y minificador CSS | LightningCSS | 🛠 |
| 117 | `empaca` | Empaquetador web | esbuild | 🛠 |
| 118 | `ensayo` | Mocks y snapshots | Vitest | ✅ `cforge test --coverage` · 🛠 mocks |
| 119 | `ficticio` | Datos falsos realistas | Faker | 🛠 |
| 120 | `contrato` | Documentación OpenAPI | Swagger | 🛠 |
| 121 | `subida` | Subida de archivos multipart | busboy | 🛠 |
| 122 | `casco` | Cabeceras de seguridad HTTP | Helmet | 🛠 |
| 123 | `acceso` | Autenticación modular | Passport, Lucia | ✅ `auth` (básico) |
| 124 | `cola` | Trabajos en segundo plano | BullMQ | 🛠 |
| 125 | `idiomas` | Internacionalización | i18next | 🛠 |
| 126 | `extremo` | APIs con tipos compartidos | tRPC | 🛠 |

### F. Audio, juegos y hardware

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 127 | `sonido` | Reproducir y capturar audio | miniaudio | ✅ `audio` |
| 128 | `mezcla` | Mezclador y decodificadores | Rodio | ✅ WAV · 🛠 MP3/OGG/FLAC |
| 129 | `estudio` | Audio en tiempo real | PortAudio | 🔗 |
| 130 | `entidades` | ECS de alto rendimiento | EnTT | 🛠 |
| 131 | `navegacion` | Pathfinding y NavMesh | Recast & Detour | ✅ `algoritmos` (Dijkstra) · 🛠 A* y NavMesh |
| 132 | `serie` | Puertos serie (Arduino) | serialport | 🛠 |
| 133 | `mando` | Dispositivos USB HID | hidapi | 🔗 |
| 134 | `pines` | GPIO, I2C y SPI | rppal | 🛠 |
| 135 | `rebote` | Física 2D determinista | Chipmunk2D | ✅ `fisica2d` |
| 136 | `espacial` | Audio 3D | OpenAL | 🛠 |

### G. Sistema, CLI y compiladores

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 137 | `terminal` | Apps de interfaz en terminal | Ratatui | 🛠 |
| 138 | `progreso` | Barras de progreso | Indicatif | 🛠 |
| 139 | `pregunta` | Prompts interactivos | Dialoguer | 🛠 |
| 140 | `vigia` | Vigilar cambios en archivos | Notify | 🛠 |
| 141 | `rastreo` | Búsqueda recursiva con comodines | Walkdir, Glob | 🛠 |
| 142 | `sistema` | CPU, RAM y procesos | sysinfo | 🛠 |
| 143 | `historia` | Repositorios Git nativos | libgit2 | 🔗 |
| 144 | `contenedor` | Controlar Docker | Bollard | 🛠 |
| 145 | `version` | Versionado semántico | semver | ✅ gestor de paquetes |
| 146 | `cronometro` | Micro-benchmarks estadísticos | Criterion | 🛠 |
| 147 | `huesped` | Ejecutar WebAssembly embebido | Wasmtime | 🛠 |
| 148 | `jit` | Código máquina en tiempo de ejecución | Cranelift | 🛠 |
| 149 | `diagnostico` | Errores con flechas y colores | Miette | 🛠 |
| 150 | `canal` | Canales sin bloqueo | Crossbeam | ✅ canales en `concurrencia` |
| 151 | `asignador` | Asignador de memoria rápido | mimalloc | ✅ asignador propio |

## Bloque 3 — Avanzadas

### H. Criptografía avanzada, seguridad y blockchain

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 152 | `sobre` | Cifrado de archivos con claves | age | 🛠 |
| 153 | `primitiva` | Cripto a prueba de errores | Tink | ✅ `crypto` (AEAD) |
| 154 | `huella` | Patrones de malware | YARA | 🔗 |
| 155 | `desarma` | Ensamblador y desensamblador | Capstone, Keystone | 🔗 |
| 156 | `emulador` | Emulación de CPU | Unicorn | 🔗 |
| 157 | `curva` | Curva secp256k1 | libsecp256k1 | 🛠 |
| 158 | `cadena` | Contratos EVM y Web3 | ethers-rs | 🛠 |
| 159 | `semilla` | Frases mnemónicas y billeteras HD | BIP39 | 🛠 |
| 160 | `paseo` | Tokens PASETO | PASETO | 🛠 |
| 161 | `federa` | OAuth2 y OpenID Connect | OAuth2 | 🛠 |
| 162 | `segundo_factor` | TOTP y Passkeys | TOTP, WebAuthn | 🛠 |
| 163 | `antivirus` | Escaneo por firmas | ClamAV | 🔗 |
| 164 | `centinela` | Detección de intrusos | Suricata | 🛠 |
| 165 | `secretos` | Secretos cifrados en repos | sops | 🛠 |
| 166 | `apreton` | Protocolo Noise | snow | 🛠 |

### I. Ciencia, ingeniería y geoespacial

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 167 | `territorio` | Datos geoespaciales | GDAL | 🔗 |
| 168 | `proyeccion` | Sistemas de coordenadas | PROJ | 🔗 |
| 169 | `geometria` | Operaciones espaciales | GEOS, Turf | 🛠 |
| 170 | `panal` | Índice hexagonal del planeta | H3 | 🛠 |
| 171 | `ciencia` | Optimización e interpolación | SciPy | 🛠 |
| 172 | `fourier` | FFT rápida | FFTW | 🛠 |
| 173 | `blas` | Matrices de alto rendimiento | OpenBLAS | 🔗 |
| 174 | `malla_geo` | Geometría computacional | CGAL | 🛠 |
| 175 | `robotica` | Física para robótica | MuJoCo | 🔗 |
| 176 | `cuaternion` | Álgebra lineal y transformaciones | nalgebra | ✅ `matematica` (básica) · 🛠 |
| 177 | `astro` | Órbitas y efemérides | NOVAS | 🛠 |
| 178 | `molecula` | Quimioinformática | RDKit | 🔗 |
| 179 | `genoma` | Bioinformática | Rust-Bio | 🛠 |
| 180 | `cientifica` | Funciones especiales y EDO | GSL | 🔗 |
| 181 | `grafos` | Grafos y rutas | petgraph | ✅ `algoritmos` (BFS, DFS, Dijkstra) · 🛠 A* |

### J. Motores de juego y realidad virtual

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 182 | `nodos` | Árbol de escenas y señales | Godot | 🛠 |
| 183 | `manipulador` | Gizmos 3D de editor | ImGuizmo | 🛠 |
| 184 | `optimalla` | Optimizar mallas y LOD | meshoptimizer | 🛠 |
| 185 | `textura` | Compresión de texturas | Basis Universal | 🛠 |
| 186 | `solido` | Física 3D multinúcleo | Jolt | ✅ `fisica3d` (básica) · 🛠 |
| 187 | `determinista` | Física reproducible | Rapier | 🛠 |
| 188 | `inmersiva` | Realidad virtual y aumentada | OpenXR | 🔗 |
| 189 | `sombreador` | Traducir shaders | naga | 🛠 |
| 190 | `mosaico` | Mapas de tiles | Tiled, LDtk | 🛠 |
| 191 | `esqueleto` | Animación por huesos 2D | Spine | 🛠 |
| 192 | `multitud` | Simulación de multitudes | DetourCrowd | 🛠 |
| 193 | `ruido` | Terrenos procedurales | FastNoiseLite | 🛠 |
| 194 | `carga3d` | Cargar OBJ y glTF | tinyobjloader | ✅ `modelo` (OBJ) · 🛠 glTF |
| 195 | `grafica` | Gráficas en tiempo real | ImPlot | 🛠 |
| 196 | `dialogo` | Narrativa interactiva | ink, YarnSpinner | 🛠 |

### K. Multimedia, documentos y finanzas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 197 | `revelado` | Imágenes masivas con poca RAM | libvips | 🔗 |
| 198 | `formato_web` | WebP y AVIF | libwebp, libavif | 🔗 |
| 199 | `escaner` | Documentos escaneados | Leptonica | 🔗 |
| 200 | `codigo_qr` | QR y códigos de barras | ZXing | 🛠 |
| 201 | `composicion` | Composición tipográfica de PDFs | Typst | 🛠 |
| 202 | `conversor` | Conversión entre formatos de documento | Pandoc | 🛠 |
| 203 | `lee_excel` | Leer .xlsx/.ods | Calamine | 🛠 |
| 204 | `dinero` | Decimales exactos | rust_decimal | 🛠 |
| 205 | `indicadores` | Análisis técnico (RSI, MACD) | TA-Lib | 🛠 |
| 206 | `derivados` | Valoración de opciones y bonos | QuantLib | 🛠 |
| 207 | `mensaje_bancario` | ISO 8583 y FIX | ISO 8583, FIX | 🛠 |
| 208 | `cobro` | Cobros idempotentes y webhooks | Stripe | 🛠 |
| 209 | `postura` | Rostro, manos y pose | MediaPipe | 🔗 |
| 210 | `tuberia` | Pipelines multimedia | GStreamer | 🔗 |
| 211 | `voz_activa` | Detección de voz | Silero VAD | 🛠 |

### L. Nube, microservicios y DevOps

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 212 | `traza` | Trazas y métricas distribuidas | OpenTelemetry | 🛠 |
| 213 | `metricas` | Métricas en tiempo real | Prometheus | 🛠 |
| 214 | `flujo` | Streaming de eventos | Kafka | 🔗 |
| 215 | `correo_rapido` | Mensajería entre microservicios | NATS | 🛠 |
| 216 | `colas` | Colas AMQP | RabbitMQ | 🛠 |
| 217 | `descubre` | Descubrimiento de servicios | etcd, Consul | 🛠 |
| 218 | `objetos` | Almacenamiento compatible con S3 | MinIO | 🛠 |
| 219 | `orquesta` | Cliente de Kubernetes | kube-rs | 🛠 |
| 220 | `infra` | Infraestructura como código | HCL | 🛠 |
| 221 | `proxy` | Proxy inverso y balanceo | Caddy, Pingora | 🛠 |
| 222 | `recolector` | Recolección de logs | Vector | 🛠 |
| 223 | `proceso` | Flujos de trabajo de larga duración | Temporal | 🛠 |
| 224 | `permisos` | ACL, RBAC y ABAC | Casbin | 🛠 |
| 225 | `interruptor` | Feature flags y pruebas A/B | OpenFeature | 🛠 |
| 226 | `entorno` | Servicios reales en pruebas | Testcontainers | 🛠 |

### M. Automatización, compiladores y sistema

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 227 | `asistente` | Servidor de lenguaje | LSP | ✅ `cforge lsp` |
| 228 | `depura` | Depuración paso a paso | DAP | 🛠 |
| 229 | `intermedio` | Optimización de código intermedio | LLVM, MLIR | 🛠 (v5) |
| 230 | `gramatica` | Combinadores de parsers | Pest, Nom | 🛠 |
| 231 | `analiza` | Compilador como servicio | Roslyn | 🛠 |
| 232 | `nucleo` | Programas en el kernel | eBPF | 🛠 |
| 233 | `anillo` | E/S asíncrona en Linux | io_uring | 🛠 |
| 234 | `ventanas_api` | APIs nativas de Windows | windows (Rust) | ✅ runtime Windows · 🛠 |
| 235 | `manzana` | APIs nativas de macOS e iOS | Cocoa | ✅ `apple` (básico) |
| 236 | `bus` | D-Bus en Linux | zbus | 🛠 |
| 237 | `teclado` | Simular teclado y ratón | Enigo | 🛠 |
| 238 | `recolecta` | Extracción web con sesiones | Fantoccini | 🛠 |
| 239 | `agenda` | Cron con zonas horarias | tokio-cron | 🛠 |
| 240 | `ident` | UUID, ULID y NanoID | uuid, ulid | 🛠 |
| 241 | `telefono` | Números telefónicos | libphonenumber | 🛠 |
| 242 | `unicode` | Normalización y ordenamiento | ICU | 🛠 |
| 243 | `buscador` | Búsqueda full-text | Tantivy | 🛠 |
| 244 | `consulta_archivos` | SQL sobre CSV, JSON y Parquet | DataFusion | 🛠 |
| 245 | `socket_web` | WebSocket RFC 6455 | Tungstenite | ✅ `red` |
| 246 | `correo` | Enviar correos con DKIM | Lettre | 🛠 |
| 247 | `bandeja` | Leer correo IMAP/POP3 | IMAP | 🛠 |
| 248 | `vecinos` | Descubrimiento mDNS | Zeroconf | 🛠 |
| 249 | `puertos` | Abrir puertos en el router | UPnP | 🛠 |
| 250 | `usb` | USB de bajo nivel | libusb | 🔗 |
| 251 | `alerta` | Reportes de errores en producción | Sentry | 🛠 |
