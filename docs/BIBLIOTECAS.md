# Ecosistema de bibliotecas de C-Forge (251)

Nombres propios de C-Forge para las 251 áreas del catálogo. Cada una se
implementa en su propio PR, en `.cfv`, con pruebas y verificada en el CI;
la columna «Inspiración» sirve para revisar la licencia antes de portar
(MIT, BSD, Apache, zlib: sí, conservando el aviso; GPL/LGPL: solo vía
`bindgen`, sin copiar código).

**Regla bilingüe:** cada biblioteca nace con nombre y funciones en español
y en inglés (`importar "dinero"` / `import "money"`), con pruebas en los dos
idiomas.

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
| 12 | `molde` / `serde` | Serialización universal | Serde | ✅ `molde` |
| 13 | `enjambre` | Paralelismo de datos | Rayon | 🛠 |
| 14 | `orden` / `cli` | Argumentos de línea de comandos | Clap | ✅ `orden` |
| 15 | `mensajero` | Cliente HTTP | Reqwest | ✅ `red` |
| 16 | `portico` | Framework web | Axum, Actix | ✅ `web` (básico) |
| 17 | `tabla` / `dataframe` | DataFrames | Polars | ✅ `tabla` |
| 18 | `elenco` / `ecs` | Entidad-Componente-Sistema | Bevy ECS | ✅ `elenco` |
| 19 | `blindaje` | TLS y cripto puras | Ring, Rustls | ✅ `crypto` · 🛠 TLS propio |
| 20 | `patron` | Expresiones regulares sin ReDoS | regex (Rust) | ✅ `regex` |
| 21 | `consulta` | Consultas perezosas sobre colecciones | LINQ | ✅ `colecciones` (parcial) |
| 22 | `ligero` | Micro-ORM | Dapper | 🛠 |
| 23 | `mapeador` | ORM con migraciones | EF Core | ✅ `db` (migraciones) · 🛠 ORM |
| 24 | `senal` | Tiempo real con reconexión | SignalR | 🛠 |
| 25 | `arbol_json` | JSON tipado y dinámico | System.Text.Json | ✅ `json` |
| 26 | `regla` / `validator` | Validación encadenada | FluentValidation | ✅ `regla` |
| 27 | `calco` / `mapper` | Mapeo entre estructuras | AutoMapper | ✅ `calco` |
| 28 | `resiste` / `resilience` | Reintentos y circuit breaker | Polly | ✅ `resiste` |
| 29 | `bitacora` / `logger` | Logs estructurados | Serilog | ✅ `bitacora` |
| 30 | `torrente` | Red asíncrona de alto tráfico | Netty | 🛠 |
| 31 | `caja` / `cache` | Colecciones avanzadas y cachés | Guava | ✅ `caja` |
| 32 | `formatos` | JSON, XML, CSV y YAML | Jackson | ✅ JSON · 🛠 resto |
| 33 | `registro` / `logging` | Registro de eventos desacoplado | SLF4J, Logback | ✅ `registro` |
| 34 | `reloj` / `cron` | Tareas programadas (cron) | Quartz | ✅ `reloj` |
| 35 | `indice` / `search` | Búsqueda de texto completo | Lucene | ✅ `indice` |
| 36 | `prueba` | Pruebas y aserciones | JUnit | ✅ `cforge test` + `afirmar` |
| 37 | `esquema` / `schema` | Validación de esquemas | Zod | ✅ `esquema` |
| 38 | `ruta` | Framework web con middlewares | Express, Hono | ✅ `web` (básico) |
| 39 | `navaja` | Utilidades funcionales | Lodash | ✅ `lista` / `algoritmos` · 🔗 npm |
| 40 | `calendario` | Fechas y zonas horarias | Day.js, Luxon | ✅ `fecha` |
| 41 | `cartero` | Cliente HTTP con interceptores | Axios | ✅ `red` · 🛠 interceptores |
| 42 | `eco` | Eventos en tiempo real | Socket.io | ✅ WebSocket en `red` |
| 43 | `modelo_db` / `orm` | Esquemas y consultas limpias | Prisma, Drizzle | ✅ `modelo_db` |
| 44 | `escena` | 3D sobre WebGL | Three.js | ✅ `gl` / `modelo` (básico) |
| 45 | `cosecha` / `scrape` | HTML con selectores CSS | Cheerio | ✅ `cosecha` |
| 46 | `tinta` / `ink` | Colores en la terminal | Chalk | ✅ `tinta` |
| 47 | `matriz` / `ndarray` | Arreglos multidimensionales | NumPy | ✅ `matriz` |
| 48 | `planilla` / `pivot` | Análisis de datos tabulares | Pandas | ✅ `planilla` |
| 49 | `api_rapida` / `fastapi` | APIs con documentación automática | FastAPI | ✅ `api_rapida` |
| 50 | `vitrina` / `rich` | Interfaces ricas en terminal | Rich | ✅ `vitrina` |
| 51 | `gradiente` / `autograd` | Tensores con autodiferenciación | PyTorch | ✅ `gradiente` |

## Bloque 2 — Áreas

### A. Inteligencia artificial y matemáticas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 52 | `oraculo` | LLM locales cuantizados | llama.cpp | 🔗 |
| 53 | `cerebro` | Ejecutar modelos entrenados | ONNX Runtime | 🔗 |
| 54 | `algebra` / `linalg` | Álgebra lineal | Eigen | ✅ `algebra` |
| 55 | `vision` | Visión por computadora | OpenCV | 🔗 |
| 56 | `vela` / `trees` | Machine learning ligero | Candle | ✅ `vela` |
| 57 | `fichas` / `tokenizers` | Tokenización (BPE, WordPiece) | Tokenizers | ✅ `fichas` |
| 58 | `vecindad` / `vectors` | Búsqueda vectorial | FAISS | ✅ `vecindad` |
| 59 | `aprende` / `ml` | ML clásico | scikit-learn | ✅ `aprende` |
| 60 | `lector` | OCR | Tesseract | 🔗 |
| 61 | `oido` | Voz a texto | Whisper.cpp | 🔗 |
| 62 | `prediccion` | Entrenar y predecir | ML.NET | 🔗 `dotnet` |
| 63 | `numerica` / `numeric` | Estadística y FFT | Math.NET | ✅ `numerica` |
| 64 | `simbolo` / `symbolic` | Matemáticas simbólicas | SymPy | ✅ `simbolo` |
| 65 | `estadistica` / `stats` | Algoritmos estadísticos | linfa | ✅ `estadistica` |
| 66 | `hibrida` / `hybrid` | Búsqueda vectorial + texto | Qdrant, Tantivy | ✅ `hibrida` |

### B. Interfaces gráficas y diseño

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 67 | `lienzo` | Motor gráfico 2D | Skia | ✅ `graficos` |
| 68 | `flex` / `flexbox` | Layout Flexbox | Yoga | ✅ `flex` |
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
| 82 | `llamada` / `protobuf` | RPC binario | gRPC, Protobuf | ✅ `llamada` |
| 83 | `veloz` | QUIC y HTTP/3 | Quinn | 🛠 |
| 84 | `buzon` | Mensajería entre procesos | ZeroMQ | 🛠 |
| 85 | `malla` | Redes P2P | libp2p | 🛠 |
| 86 | `tunel` | VPN criptográfica | WireGuard | 🛠 |
| 87 | `certifica` | Certificados HTTPS automáticos | ACME | 🛠 |
| 88 | `ficha` | Tokens JWT/JWE | jose | ✅ `auth` (JWT) |
| 89 | `clave` / `password` | Hash de contraseñas | Argon2, bcrypt | ✅ `clave` |
| 90 | `sonda` | Captura de paquetes | libpcap | 🔗 |
| 91 | `consenso` / `raft` | Consenso distribuido | Raft | ✅ `consenso` |
| 92 | `sensor` / `mqtt` | Mensajería IoT | MQTT | ✅ `sensor` |
| 93 | `directo` | Audio/video P2P | WebRTC | 🛠 |
| 94 | `transporte` | Transferencia multiprotocolo | libcurl | ✅ HTTP en `red` · 🔗 |
| 95 | `freno` / `ratelimit` | Límite de peticiones | Governor | ✅ `freno` |
| 96 | `consola_remota` | SSH y SFTP | libssh2 | 🔗 |

### D. Bases de datos y formatos

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 97 | `archivo_kv` | Clave-valor en disco | RocksDB | 🛠 |
| 98 | `analitica` | SQL analítico embebido | DuckDB | 🔗 |
| 99 | `cofre` | Base embebida ACID | sled, redb | 🛠 |
| 100 | `paquete_bin` / `msgpack` | Serialización binaria compacta | MessagePack | ✅ `paquete_bin` |
| 101 | `sin_copia` | Serialización zero-copy | FlatBuffers | 🛠 |
| 102 | `columnas` | Formato columnar | Arrow, Parquet | 🛠 |
| 103 | `hoja` / `xlsx` | Hojas de cálculo .xlsx | libxlsxwriter | ✅ `hoja` |
| 104 | `documento` / `pdf` | PDF: crear, leer y firmar | PDFium, lopdf | ✅ `documento` |
| 105 | `archivador` / `archive` | ZIP/TAR seguros | libarchive | ✅ `archivador` |
| 106 | `ajustes` / `config` | TOML y YAML estrictos | toml, yaml-rust | ✅ `ajustes` |
| 107 | `marcado` / `markdown` | Markdown a HTML | pulldown-cmark | ✅ `marcado` |
| 108 | `sintaxis` | Parser incremental | tree-sitter | 🔗 |
| 109 | `xml` | XML rápido | quick-xml | ✅ `xml` |
| 110 | `csv` | CSV gigantes (RFC 4180) | csv-rs | ✅ `csv` |
| 111 | `memoria_rapida` | Cliente Redis con clústeres | fred | ✅ `redis` · 🛠 clústeres |

### E. Web, frontend, APIs y pruebas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 112 | `grafo_api` / `graphql` | Servidor GraphQL | async-graphql | ✅ `grafo_api` |
| 113 | `plantilla` / `template` | Plantillas HTML | Tera, Handlebars | ✅ `plantilla` |
| 114 | `piloto` | Navegadores automatizados | Playwright | 🛠 |
| 115 | `atributo` | Interactividad por atributos HTML | htmx | 🛠 |
| 116 | `css` | Parser y minificador CSS | LightningCSS | ✅ `css` |
| 117 | `empaca` | Empaquetador web | esbuild | 🛠 |
| 118 | `ensayo` | Mocks y snapshots | Vitest | ✅ `cforge test --coverage` · 🛠 mocks |
| 119 | `ficticio` / `faker` | Datos falsos realistas | Faker | ✅ `ficticio` |
| 120 | `contrato` / `openapi` | Documentación OpenAPI | Swagger | ✅ `contrato` |
| 121 | `subida` / `multipart` | Subida de archivos multipart | busboy | ✅ `subida` |
| 122 | `casco` / `helmet` | Cabeceras de seguridad HTTP | Helmet | ✅ `casco` |
| 123 | `acceso` | Autenticación modular | Passport, Lucia | ✅ `auth` (básico) |
| 124 | `cola` / `queue` | Trabajos en segundo plano | BullMQ | ✅ `cola` |
| 125 | `idiomas` / `i18n` | Internacionalización | i18next | ✅ `idiomas` |
| 126 | `extremo` | APIs con tipos compartidos | tRPC | 🛠 |

### F. Audio, juegos y hardware

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 127 | `sonido` | Reproducir y capturar audio | miniaudio | ✅ `audio` |
| 128 | `mezcla` | Mezclador y decodificadores | Rodio | ✅ WAV · 🛠 MP3/OGG/FLAC |
| 129 | `estudio` | Audio en tiempo real | PortAudio | 🔗 |
| 130 | `entidades` / `entities` | ECS de alto rendimiento | EnTT | ✅ `entidades` |
| 131 | `navegacion` / `navmesh` | Pathfinding y NavMesh | Recast & Detour | ✅ `navegacion` |
| 132 | `serie` | Puertos serie (Arduino) | serialport | 🛠 |
| 133 | `mando` | Dispositivos USB HID | hidapi | 🔗 |
| 134 | `pines` | GPIO, I2C y SPI | rppal | 🛠 |
| 135 | `rebote` | Física 2D determinista | Chipmunk2D | ✅ `fisica2d` |
| 136 | `espacial` | Audio 3D | OpenAL | 🛠 |

### G. Sistema, CLI y compiladores

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 137 | `terminal` | Apps de interfaz en terminal | Ratatui | 🛠 |
| 138 | `progreso` / `progress` | Barras de progreso | Indicatif | ✅ `progreso` |
| 139 | `pregunta` / `prompt` | Prompts interactivos | Dialoguer | ✅ `pregunta` |
| 140 | `vigia` | Vigilar cambios en archivos | Notify | 🛠 |
| 141 | `rastreo` / `glob` | Búsqueda recursiva con comodines | Walkdir, Glob | ✅ `rastreo` |
| 142 | `sistema` | CPU, RAM y procesos | sysinfo | 🛠 |
| 143 | `historia` | Repositorios Git nativos | libgit2 | 🔗 |
| 144 | `contenedor` | Controlar Docker | Bollard | 🛠 |
| 145 | `version` | Versionado semántico | semver | ✅ gestor de paquetes |
| 146 | `cronometro` / `bench` | Micro-benchmarks estadísticos | Criterion | ✅ `cronometro` |
| 147 | `huesped` | Ejecutar WebAssembly embebido | Wasmtime | 🛠 |
| 148 | `jit` | Código máquina en tiempo de ejecución | Cranelift | 🛠 |
| 149 | `diagnostico` / `diagnostics` | Errores con flechas y colores | Miette | ✅ `diagnostico` |
| 150 | `canal` | Canales sin bloqueo | Crossbeam | ✅ canales en `concurrencia` |
| 151 | `asignador` | Asignador de memoria rápido | mimalloc | ✅ asignador propio |

## Bloque 3 — Avanzadas

### H. Criptografía avanzada, seguridad y blockchain

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 152 | `sobre` / `envelope` | Cifrado de archivos con claves | age | ✅ `sobre` |
| 153 | `primitiva` | Cripto a prueba de errores | Tink | ✅ `crypto` (AEAD) |
| 154 | `huella` | Patrones de malware | YARA | 🔗 |
| 155 | `desarma` | Ensamblador y desensamblador | Capstone, Keystone | 🔗 |
| 156 | `emulador` | Emulación de CPU | Unicorn | 🔗 |
| 157 | `curva` / `secp256k1` | Curva secp256k1 | libsecp256k1 | ✅ `curva` |
| 158 | `cadena` / `evm` | Contratos EVM y Web3 | ethers-rs | ✅ `cadena` |
| 159 | `semilla` / `hdwallet` | Frases mnemónicas y billeteras HD | BIP39 | ✅ `semilla` |
| 160 | `paseo` / `paseto` | Tokens PASETO | PASETO | ✅ `paseo` |
| 161 | `federa` / `oidc` | OAuth2 y OpenID Connect | OAuth2 | ✅ `federa` |
| 162 | `segundo_factor` / `totp` | TOTP y Passkeys | TOTP, WebAuthn | ✅ `segundo_factor` |
| 163 | `antivirus` | Escaneo por firmas | ClamAV | 🔗 |
| 164 | `centinela` | Detección de intrusos | Suricata | 🛠 |
| 165 | `secretos` / `secrets` | Secretos cifrados en repos | sops | ✅ `secretos` |
| 166 | `apreton` / `noise_protocol` | Protocolo Noise | snow | ✅ `apreton` |

### I. Ciencia, ingeniería y geoespacial

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 167 | `territorio` | Datos geoespaciales | GDAL | 🔗 |
| 168 | `proyeccion` | Sistemas de coordenadas | PROJ | 🔗 |
| 169 | `geometria` / `geo` | Operaciones espaciales | GEOS, Turf | ✅ `geometria` |
| 170 | `panal` / `hexgrid` | Índice hexagonal del planeta | H3 | ✅ `panal` |
| 171 | `ciencia` / `science` | Optimización e interpolación | SciPy | ✅ `ciencia` |
| 172 | `fourier` / `fft` | FFT rápida | FFTW | ✅ `fourier` |
| 173 | `blas` | Matrices de alto rendimiento | OpenBLAS | 🔗 |
| 174 | `malla_geo` / `geometry2d` | Geometría computacional | CGAL | ✅ `malla_geo` |
| 175 | `robotica` | Física para robótica | MuJoCo | 🔗 |
| 176 | `cuaternion` / `quaternion` | Álgebra lineal y transformaciones | nalgebra | ✅ `cuaternion` |
| 177 | `astro` / `astronomy` | Órbitas y efemérides | NOVAS | ✅ `astro` |
| 178 | `molecula` | Quimioinformática | RDKit | 🔗 |
| 179 | `genoma` / `bio` | Bioinformática | Rust-Bio | ✅ `genoma` |
| 180 | `cientifica` | Funciones especiales y EDO | GSL | 🔗 |
| 181 | `grafos` / `graph` | Grafos y rutas | petgraph | ✅ `grafos` |

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
| 190 | `mosaico` / `tilemap` | Mapas de tiles | Tiled, LDtk | ✅ `mosaico` |
| 191 | `esqueleto` | Animación por huesos 2D | Spine | 🛠 |
| 192 | `multitud` / `crowd` | Simulación de multitudes | DetourCrowd | ✅ `multitud` |
| 193 | `ruido` / `noise` | Terrenos procedurales | FastNoiseLite | ✅ `ruido` |
| 194 | `carga3d` | Cargar OBJ y glTF | tinyobjloader | ✅ `modelo` (OBJ) · 🛠 glTF |
| 195 | `grafica` / `chart` | Gráficas en tiempo real | ImPlot | ✅ `grafica` |
| 196 | `dialogo` / `dialogue` | Narrativa interactiva | ink, YarnSpinner | ✅ `dialogo` |

### K. Multimedia, documentos y finanzas

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 197 | `revelado` | Imágenes masivas con poca RAM | libvips | 🔗 |
| 198 | `formato_web` | WebP y AVIF | libwebp, libavif | 🔗 |
| 199 | `escaner` | Documentos escaneados | Leptonica | 🔗 |
| 200 | `codigo_qr` / `qrcode` | QR y códigos de barras | ZXing | ✅ `codigo_qr` |
| 201 | `composicion` / `typeset` | Composición tipográfica de PDFs | Typst | ✅ `composicion` |
| 202 | `conversor` | Conversión entre formatos de documento | Pandoc | 🛠 |
| 203 | `lee_excel` / `read_xlsx` | Leer .xlsx/.ods | Calamine | ✅ `lee_excel` |
| 204 | `dinero` / `money` | Decimales exactos | rust_decimal | ✅ `dinero` |
| 205 | `indicadores` / `ta` | Análisis técnico (RSI, MACD) | TA-Lib | ✅ `indicadores` |
| 206 | `derivados` / `quant` | Valoración de opciones y bonos | QuantLib | ✅ `derivados` |
| 207 | `mensaje_bancario` / `iso8583` | ISO 8583 y FIX | ISO 8583, FIX | ✅ `mensaje_bancario` |
| 208 | `cobro` / `payments` | Cobros idempotentes y webhooks | Stripe | ✅ `cobro` |
| 209 | `postura` | Rostro, manos y pose | MediaPipe | 🔗 |
| 210 | `tuberia` | Pipelines multimedia | GStreamer | 🔗 |
| 211 | `voz_activa` | Detección de voz | Silero VAD | 🛠 |

### L. Nube, microservicios y DevOps

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 212 | `traza` / `tracing` | Trazas y métricas distribuidas | OpenTelemetry | ✅ `traza` |
| 213 | `metricas` / `metrics` | Métricas en tiempo real | Prometheus | ✅ `metricas` |
| 214 | `flujo` | Streaming de eventos | Kafka | 🔗 |
| 215 | `correo_rapido` | Mensajería entre microservicios | NATS | 🛠 |
| 216 | `colas` | Colas AMQP | RabbitMQ | 🛠 |
| 217 | `descubre` | Descubrimiento de servicios | etcd, Consul | 🛠 |
| 218 | `objetos` / `s3` | Almacenamiento compatible con S3 | MinIO | ✅ `objetos` |
| 219 | `orquesta` | Cliente de Kubernetes | kube-rs | 🛠 |
| 220 | `infra` / `hcl` | Infraestructura como código | HCL | ✅ `infra` |
| 221 | `proxy` | Proxy inverso y balanceo | Caddy, Pingora | 🛠 |
| 222 | `recolector` | Recolección de logs | Vector | 🛠 |
| 223 | `proceso` | Flujos de trabajo de larga duración | Temporal | 🛠 |
| 224 | `permisos` / `rbac` | ACL, RBAC y ABAC | Casbin | ✅ `permisos` |
| 225 | `interruptor` / `flags` | Feature flags y pruebas A/B | OpenFeature | ✅ `interruptor` |
| 226 | `entorno` | Servicios reales en pruebas | Testcontainers | 🛠 |

### M. Automatización, compiladores y sistema

| # | Nombre | Para qué | Inspiración | Estado |
|---|---|---|---|---|
| 227 | `asistente` | Servidor de lenguaje | LSP | ✅ `cforge lsp` |
| 228 | `depura` | Depuración paso a paso | DAP | 🛠 |
| 229 | `intermedio` | Optimización de código intermedio | LLVM, MLIR | 🛠 (v5) |
| 230 | `gramatica` / `parser` | Combinadores de parsers | Pest, Nom | ✅ `gramatica` |
| 231 | `analiza` | Compilador como servicio | Roslyn | 🛠 |
| 232 | `nucleo` | Programas en el kernel | eBPF | 🛠 |
| 233 | `anillo` | E/S asíncrona en Linux | io_uring | 🛠 |
| 234 | `ventanas_api` | APIs nativas de Windows | windows (Rust) | ✅ runtime Windows · 🛠 |
| 235 | `manzana` | APIs nativas de macOS e iOS | Cocoa | ✅ `apple` (básico) |
| 236 | `bus` | D-Bus en Linux | zbus | 🛠 |
| 237 | `teclado` | Simular teclado y ratón | Enigo | 🛠 |
| 238 | `recolecta` / `crawler` | Extracción web con sesiones | Fantoccini | ✅ `recolecta` |
| 239 | `agenda` / `schedule` | Cron con zonas horarias | tokio-cron | ✅ `agenda` |
| 240 | `ident` / `ids` | UUID, ULID y NanoID | uuid, ulid | ✅ `ident` |
| 241 | `telefono` / `phone` | Números telefónicos | libphonenumber | ✅ `telefono` |
| 242 | `unicode` / `unicode_en` | Normalización y ordenamiento | ICU | ✅ `unicode` |
| 243 | `buscador` / `fulltext` | Búsqueda full-text | Tantivy | ✅ `buscador` |
| 244 | `consulta_archivos` / `sqlfiles` | SQL sobre CSV, JSON y Parquet | DataFusion | ✅ `consulta_archivos` |
| 245 | `socket_web` | WebSocket RFC 6455 | Tungstenite | ✅ `red` |
| 246 | `correo` | Enviar correos con DKIM | Lettre | 🛠 |
| 247 | `bandeja` / `mailbox` | Leer correo IMAP/POP3 | IMAP | ✅ `bandeja` |
| 248 | `vecinos` | Descubrimiento mDNS | Zeroconf | 🛠 |
| 249 | `puertos` | Abrir puertos en el router | UPnP | 🛠 |
| 250 | `usb` | USB de bajo nivel | libusb | 🔗 |
| 251 | `alerta` / `errors` | Reportes de errores en producción | Sentry | ✅ `alerta` |
