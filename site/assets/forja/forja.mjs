// Generado por cforge build --target wasm. No editar.
const FUNCIONES = {"forja_entrada": 2069, "forja_listas": 2072, "tsen": 2109, "tcos": 2118, "azar": 2130, "gauss": 2144, "forja_paso": 2570};
const EXTERNAS = [["js", "forja_entrada", [5], 5], ["js", "forja_listas", [0, 0, 0, 0, 5], 4]];
const WASM = "./forja.wasm";
// ── Cargador de C-Forge para WebAssembly (navegador y Node.js) ──────────────
// Uso en el navegador:
//   import { iniciar } from "./app.mjs";
//   const cf = await iniciar({ js: { mi_funcion: (x) => x * 2 } });
//   cf.llamar("nombre_de_funcion", 3);
// En Node.js: node app.mjs [argumentos]
// El programa usa el runtime de Linux x86-64; este cargador atiende sus
// llamadas al sistema sobre la memoria lineal del módulo.

const ES_NODE = typeof process !== "undefined" && !!(process.versions && process.versions.node);
const PILA = 8 * 1024 * 1024;
const RESERVA = 1024 * 1024;

class Salida extends Error {
  constructor(codigo) { super("C-Forge terminó con código " + codigo); this.codigo = codigo; }
}

export async function iniciar(opciones = {}) {
  const js = opciones.js || {};
  const argumentos = opciones.argumentos || [];
  const web = opciones.web !== undefined ? !!opciones.web : !ES_NODE;
  const escribir = opciones.escribir || null;
  let fs = null;
  if (ES_NODE) fs = await import("node:fs");

  // Bytes del módulo.
  let bytes = opciones.wasm;
  if (!bytes) {
    const url = new URL(WASM, import.meta.url);
    bytes = ES_NODE ? fs.readFileSync(url) : await (await fetch(url)).arrayBuffer();
  }

  let memoria, ejecutar, pilaInicial = 0n, monticulo = 0, reservaTextos = 0;
  const dec = new TextDecoder(), enc = new TextEncoder();
  const u8 = () => new Uint8Array(memoria.buffer);
  const dv = () => new DataView(memoria.buffer);
  const pendiente = { 1: "", 2: "" };
  const archivos = new Map();
  let siguienteFd = 3;

  function salir(fd, texto) {
    if (escribir) { escribir(fd, texto); return; }
    if (ES_NODE) { fs.writeSync(fd, texto); return; }
    pendiente[fd] += texto;
    let i;
    while ((i = pendiente[fd].indexOf("\n")) >= 0) {
      const linea = pendiente[fd].slice(0, i); pendiente[fd] = pendiente[fd].slice(i + 1);
      (fd === 2 ? console.error : console.log)(linea);
    }
  }
  function cadena(p) {
    const m = u8(); let f = p;
    while (m[f] !== 0) f++;
    return dec.decode(m.subarray(p, f));
  }
  function crecer(hasta) {
    const falta = hasta - memoria.buffer.byteLength;
    if (falta > 0) memoria.grow(Math.ceil(falta / 65536));
  }
  // Texto devuelto por una externa: en la reserva (el runtime lo copia al instante).
  function textoEnMemoria(s) {
    const b = enc.encode(String(s));
    if (b.length + 1 > RESERVA) throw new Error("C-Forge: texto demasiado largo para devolver desde JavaScript");
    u8().set(b, reservaTextos); u8()[reservaTextos + b.length] = 0;
    return BigInt(reservaTextos);
  }
  const f64 = new Float64Array(1), i64 = new BigInt64Array(f64.buffer);
  const bitsANumero = (b) => { i64[0] = b; return f64[0]; };
  const numeroABits = (n) => { f64[0] = n; return i64[0]; };

  const E = { ENOENT: -2, EBADF: -9, ENOSYS: -38 };
  function sys(nr, a1, a2, a3) {
    const n = Number(nr);
    switch (n) {
      case 0: { // read
        const fd = Number(a1), buf = Number(a2), cuanto = Number(a3);
        if (!ES_NODE) return 0n;
        try { return BigInt(fs.readSync(fd === 0 ? 0 : archivos.get(fd), u8(), buf, cuanto, null)); } catch { return BigInt(E.EBADF); }
      }
      case 1: { // write
        const fd = Number(a1), buf = Number(a2), cuanto = Number(a3);
        if (fd === 1 || fd === 2) { salir(fd, dec.decode(u8().subarray(buf, buf + cuanto))); return BigInt(cuanto); }
        if (ES_NODE && archivos.has(fd)) return BigInt(fs.writeSync(archivos.get(fd), u8(), buf, cuanto));
        return BigInt(E.EBADF);
      }
      case 2: { // open
        if (!ES_NODE) return BigInt(E.ENOENT);
        const ruta = cadena(Number(a1)), banderas = Number(a2);
        const modo = (banderas & 3) === 0 ? "r" : (banderas & 1024) ? "a" : (banderas & 64) ? "w" : "r+";
        try { const fd = siguienteFd++; archivos.set(fd, fs.openSync(ruta, modo)); return BigInt(fd); } catch { return BigInt(E.ENOENT); }
      }
      case 3: { // close
        const fd = Number(a1);
        if (archivos.has(fd)) { fs.closeSync(archivos.get(fd)); archivos.delete(fd); }
        return 0n;
      }
      case 9: { // mmap: memoria nueva al final (múltiplos de 64 KiB)
        const cuanto = Math.ceil(Number(a2) / 65536) * 65536;
        const dir = monticulo; monticulo += cuanto; crecer(monticulo);
        u8().fill(0, dir, dir + cuanto);
        return BigInt(dir);
      }
      case 11: case 24: case 202: case 35: return 0n; // munmap, sched_yield, futex, nanosleep
      case 39: return 1n; // getpid
      case 228: { // clock_gettime
        const ns = BigInt(Math.round((typeof performance !== "undefined" ? performance.timeOrigin + performance.now() : Date.now()) * 1e6));
        const p = Number(a2);
        dv().setBigInt64(p, ns / 1000000000n, true); dv().setBigInt64(p + 8, ns % 1000000000n, true);
        return 0n;
      }
      case 318: { // getrandom
        const p = Number(a1), cuanto = Number(a2);
        for (let i = 0; i < cuanto; i += 65536) crypto.getRandomValues(u8().subarray(p + i, p + Math.min(cuanto, i + 65536)));
        return BigInt(cuanto);
      }
      case 79: { // getcwd
        const d = enc.encode((ES_NODE ? process.cwd() : "/") + "\0");
        u8().set(d, Number(a1)); return BigInt(d.length);
      }
      case 60: case 231: throw new Salida(Number(a1)); // exit, exit_group
      case 1000: { // fin del programa principal: en la web sigue vivo (eventos)
        if (web) return 0n;
        throw new Salida(Number(a1));
      }
      case 1001: throw new Error("C-Forge (WebAssembly): los hilos (tarea) no están disponibles en el navegador");
      case 1002: case 1003: throw new Error("C-Forge (WebAssembly): no hay llamadas a C; usa extern \"js\"");
      case 1005: throw new Error("C-Forge (WebAssembly): hilos no disponibles");
      default: return BigInt(E.ENOSYS);
    }
  }

  // ── stdlib/navegador.cfv: DOM, eventos, animación, lienzo 2D y partículas ──
  let programa = null, dato = 0, evento = null, arrastre = { origen: "", destino: "" };
  const raton = { x: 0, y: 0, activo: false };
  if (typeof window !== "undefined") {
    window.addEventListener("pointermove", (e) => { raton.x = e.clientX; raton.y = e.clientY; raton.activo = true; }, { passive: true });
    document.addEventListener("pointerleave", () => { raton.activo = false; });
  }
  const $ = (s) => { const e = document.querySelector(s); if (!e) throw new Error("C-Forge: no existe el elemento " + s); return e; };
  let lienzo2d = null;
  const despachar = (id, valor) => { dato = Math.round(valor || 0); programa.llamar("navegador_despachar", id); };
  const NAVEGADOR = {
    nav_texto: (s, v) => { $(s).textContent = v; },
    nav_html: (s, v) => { $(s).innerHTML = v; },
    nav_estilo: (s, p, v) => { $(s).style.setProperty(p, v); },
    nav_atributo: (s, n, v) => { $(s).setAttribute(n, v); },
    nav_clase: (s, c, a) => { $(s).classList.toggle(c, a); },
    nav_valor: (s) => $(s).value ?? "",
    nav_consola: (v) => console.log(v),
    nav_ancho: () => innerWidth, nav_alto: () => innerHeight,
    nav_scroll: () => { const m = document.documentElement.scrollHeight - innerHeight; return m > 0 ? Math.round(scrollY / m * 1000) : 0; },
    nav_scroll_y: () => Math.round(scrollY),
    nav_mouse_x: () => Math.round(raton.x), nav_mouse_y: () => Math.round(raton.y), nav_mouse_activo: () => raton.activo,
    nav_tiempo: () => performance.now(), nav_dato: () => dato,
    nav_registrar_animacion: (id) => { const cuadro = (t) => { despachar(id, t); requestAnimationFrame(cuadro); }; requestAnimationFrame(cuadro); },
    nav_registrar_evento: (s, ev, id) => { (s === "window" ? window : s === "document" ? document : $(s)).addEventListener(ev, (e) => { evento = e; despachar(id, 0); }); },
    // Datos del último evento: "tecla", "id" (elemento con id más cercano),
    // "origen"/"destino" (arrastrar y soltar), "x", "y", "valor", "tipo".
    nav_evento: (campo) => {
      const e = evento;
      if (campo === "origen") return arrastre.origen;
      if (campo === "destino") return arrastre.destino;
      if (!e) return "";
      switch (campo) {
        case "tecla": return e.key ?? "";
        case "id": { const t = e.target && e.target.closest ? e.target.closest("[id]") : null; return t ? t.id : ""; }
        case "x": return String(Math.round(e.clientX ?? 0));
        case "y": return String(Math.round(e.clientY ?? 0));
        case "valor": return e.target && e.target.value !== undefined ? String(e.target.value) : "";
        case "tipo": return e.type ?? "";
        default: return "";
      }
    },
    // Atajo de teclado en todo el documento ("Escape", "Enter", "ArrowLeft"…).
    nav_registrar_tecla: (tecla, id) => {
      document.addEventListener("keydown", (e) => {
        if (e.key !== tecla) return;
        evento = e;
        despachar(id, 0);
      });
    },
    // Arrastrar y soltar con delegación: sirve también para elementos que se
    // crean después (nav_html). Clases: "arrastrando" en el origen y
    // "sobre" en el destino mientras pasa por encima.
    nav_registrar_arrastre: (origenes, destinos, id) => {
      const marcar = () => document.querySelectorAll(origenes).forEach((el) => { el.draggable = true; });
      marcar();
      new MutationObserver(marcar).observe(document.body, { childList: true, subtree: true });
      const de = (e, s) => (e.target && e.target.closest ? e.target.closest(s) : null);
      document.addEventListener("dragstart", (e) => {
        const el = de(e, origenes); if (!el) return;
        arrastre.origen = el.id || "";
        e.dataTransfer.setData("text/plain", el.id || "");
        e.dataTransfer.effectAllowed = "move";
        el.classList.add("arrastrando");
      });
      document.addEventListener("dragend", (e) => { const el = de(e, origenes); if (el) el.classList.remove("arrastrando"); });
      document.addEventListener("dragover", (e) => { const d = de(e, destinos); if (!d) return; e.preventDefault(); e.dataTransfer.dropEffect = "move"; d.classList.add("sobre"); });
      document.addEventListener("dragleave", (e) => { const d = de(e, destinos); if (d && !d.contains(e.relatedTarget)) d.classList.remove("sobre"); });
      document.addEventListener("drop", (e) => {
        const d = de(e, destinos); if (!d) return;
        e.preventDefault();
        d.classList.remove("sobre");
        arrastre.destino = d.id || "";
        evento = e;
        despachar(id, 0);
      });
    },
    // Estilos desde C-Forge (sin archivo .css aparte).
    nav_css: (css) => { const st = document.createElement("style"); st.textContent = css; document.head.appendChild(st); },
    nav_lienzo: (s) => { const c = $(s); const d = Math.min(devicePixelRatio || 1, 2); c.width = c.clientWidth * d; c.height = c.clientHeight * d; lienzo2d = c.getContext("2d"); lienzo2d.setTransform(d, 0, 0, d, 0, 0); return c.clientWidth; },
    nav_limpiar: (color) => { const c = lienzo2d.canvas; lienzo2d.save(); lienzo2d.setTransform(1, 0, 0, 1, 0, 0); lienzo2d.fillStyle = color; lienzo2d.fillRect(0, 0, c.width, c.height); lienzo2d.restore(); },
    nav_rect: (x, y, w, h, color) => { lienzo2d.fillStyle = color; lienzo2d.fillRect(x, y, w, h); },
    nav_circulo: (x, y, r, color) => { lienzo2d.fillStyle = color; lienzo2d.beginPath(); lienzo2d.arc(x, y, r, 0, 6.2832); lienzo2d.fill(); },
    nav_linea: (x1, y1, x2, y2, g, color) => { lienzo2d.strokeStyle = color; lienzo2d.lineWidth = g; lienzo2d.beginPath(); lienzo2d.moveTo(x1, y1); lienzo2d.lineTo(x2, y2); lienzo2d.stroke(); },
    nav_escribir: (x, y, t, tam, color) => { lienzo2d.fillStyle = color; lienzo2d.font = tam + "px system-ui, sans-serif"; lienzo2d.fillText(t, x, y); },
    nav_particulas_crudo: (s, x, y, z, c, n) => particulas(s, [x, y, z, c], n),
    // Lienzo RGBA de graficos.cfv (renderizado en C-Forge) → <canvas>.
    nav_lienzo_pintar: (s, dir, w, h) => {
      const c = $(s);
      if (c.width !== w || c.height !== h) { c.width = w; c.height = h; }
      const px = new Uint8ClampedArray(memoria.buffer, Number(dir), w * h * 4).slice();
      c.getContext("2d").putImageData(new ImageData(px, w, h), 0, 0);
    },
    // Elementos por índice (querySelectorAll): el i-ésimo que calza con el selector.
    nav_cuantos: (s) => document.querySelectorAll(s).length,
    nav_clase_n: (s, i, c, a) => { const e = document.querySelectorAll(s)[i]; if (e) e.classList.toggle(c, a); },
    nav_estilo_n: (s, i, p, v) => { const e = document.querySelectorAll(s)[i]; if (e) e.style.setProperty(p, v); },
    // Caja en pantalla: "arriba", "abajo", "izquierda", "derecha", "ancho", "alto".
    nav_caja: (s, i, campo) => {
      const e = document.querySelectorAll(s)[i]; if (!e) return 0;
      const r = e.getBoundingClientRect();
      return { arriba: r.top, abajo: r.bottom, izquierda: r.left, derecha: r.right, ancho: r.width, alto: r.height }[campo] ?? 0;
    },
    // Media query: nav_medio("(prefers-reduced-motion: reduce)").
    nav_medio: (q) => typeof matchMedia === "function" && matchMedia(q).matches,
    // Lienzo 2D: rellenos, degradados, rutas, recortes, transparencia y grano.
    nav_lienzo_alto: () => (lienzo2d ? lienzo2d.canvas.clientHeight : 0),
    nav_relleno: (color) => { lienzo2d.fillStyle = color; },
    nav_trazo: (color, g) => { lienzo2d.strokeStyle = color; lienzo2d.lineWidth = g; },
    nav_relleno_lineal: (x0, y0, x1, y1, paradas) => { const g = lienzo2d.createLinearGradient(x0, y0, x1, y1); pintarParadas(g, paradas); lienzo2d.fillStyle = g; },
    nav_relleno_radial: (x0, y0, r0, x1, y1, r1, paradas) => { const g = lienzo2d.createRadialGradient(x0, y0, r0, x1, y1, r1); pintarParadas(g, paradas); lienzo2d.fillStyle = g; },
    nav_rellenar_rect: (x, y, w, h) => { lienzo2d.fillRect(x, y, w, h); },
    nav_ruta_nueva: () => { lienzo2d.beginPath(); },
    nav_ruta_mover: (x, y) => { lienzo2d.moveTo(x, y); },
    nav_ruta_linea: (x, y) => { lienzo2d.lineTo(x, y); },
    nav_ruta_arco: (x, y, r, a0, a1, anti) => { lienzo2d.arc(x, y, r, a0, a1, anti); },
    nav_ruta_rombo: (x, y, w, h) => { lienzo2d.moveTo(x, y - h); lienzo2d.lineTo(x + w, y); lienzo2d.lineTo(x, y + h); lienzo2d.lineTo(x - w, y); lienzo2d.closePath(); },
    nav_ruta_cerrar: () => { lienzo2d.closePath(); },
    nav_rellenar: () => { lienzo2d.fill(); },
    nav_trazar: () => { lienzo2d.stroke(); },
    nav_recortar: () => { lienzo2d.clip(); },
    nav_guardar: () => { lienzo2d.save(); },
    nav_restaurar: () => { lienzo2d.restore(); },
    nav_alfa: (a) => { lienzo2d.globalAlpha = a; },
    nav_mezcla: (modo) => { lienzo2d.globalCompositeOperation = modo; },
    nav_sombra: (color, desenfoque) => { lienzo2d.shadowColor = color; lienzo2d.shadowBlur = desenfoque; },
    nav_grano: (alfa, dx, dy, modo) => {
      if (!grano) {
        grano = document.createElement("canvas"); grano.width = grano.height = 180;
        const g = grano.getContext("2d"), img = g.createImageData(180, 180);
        for (let k = 0; k < img.data.length; k += 4) { const v = Math.random() * 255; img.data[k] = img.data[k + 1] = img.data[k + 2] = v; img.data[k + 3] = 255; }
        g.putImageData(img, 0, 0);
      }
      const c = lienzo2d.canvas;
      lienzo2d.save(); lienzo2d.globalAlpha = alfa; lienzo2d.globalCompositeOperation = modo || "source-over";
      lienzo2d.translate(-(dx % 180), -(dy % 180)); lienzo2d.fillStyle = lienzo2d.createPattern(grano, "repeat");
      lienzo2d.fillRect(0, 0, c.clientWidth + 180, c.clientHeight + 180); lienzo2d.restore();
    },
  };
  // Paradas de un degradado: "0 #D5C6B1; 0.45 rgba(228,184,142,.5); 1 #E9A56E".
  let grano = null;
  function pintarParadas(g, paradas) {
    for (const p of String(paradas).split(";")) {
      const t = p.trim(); if (!t) continue;
      const i = t.indexOf(" ");
      g.addColorStop(parseFloat(t.slice(0, i)), t.slice(i + 1).trim());
    }
  }
  // Partículas: listas de enteros etiquetados (2v + 1) en milésimas, leídas
  // directo de la memoria del módulo y dibujadas como puntos aditivos.
  const dibujos = new Map();
  function particulas(selector, listas, n) {
    let d = dibujos.get(selector);
    if (!d) {
      const c = $(selector), gl = c.getContext("webgl2", { alpha: true, premultipliedAlpha: false });
      if (!gl) throw new Error("C-Forge: WebGL2 no disponible");
      const sh = (t, f) => { const o = gl.createShader(t); gl.shaderSource(o, f); gl.compileShader(o); if (!gl.getShaderParameter(o, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(o)); return o; };
      const p = gl.createProgram();
      gl.attachShader(p, sh(gl.VERTEX_SHADER, "#version 300 es\nlayout(location=0) in float x; layout(location=1) in float y; layout(location=2) in float z; layout(location=3) in float k;\nuniform float asp, tam; out float calor;\nvoid main(){ vec4 q = (vec4(x, y, z, k) - 1.0) * 0.0005; float w = 6.0 - q.z; float f = 2.1445;\n gl_Position = vec4(q.x * f / asp, q.y * f, (w - 0.1) / 40.0 * w, w); gl_PointSize = tam * (1.0 + q.w * 1.6) / w; calor = q.w; }"));
      gl.attachShader(p, sh(gl.FRAGMENT_SHADER, "#version 300 es\nprecision mediump float; in float calor; out vec4 color;\nvoid main(){ vec2 d = gl_PointCoord - 0.5; float a = exp(-dot(d, d) * 16.0); vec3 c = mix(vec3(1.0, 0.416, 0.196), vec3(1.0, 0.78, 0.35), smoothstep(0.15, 0.6, calor)); c = mix(c, vec3(1.0), smoothstep(0.6, 1.0, calor)); color = vec4(c, a * 0.75); }"));
      gl.linkProgram(p);
      const vao = gl.createVertexArray(); gl.bindVertexArray(vao);
      const bufs = [0, 1, 2, 3].map((b) => { const o = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, o); gl.bufferData(gl.ARRAY_BUFFER, n * 8, gl.DYNAMIC_DRAW); gl.enableVertexAttribArray(b); gl.vertexAttribPointer(b, 1, gl.INT, false, 8, 0); return o; });
      d = { c, gl, p, vao, bufs, asp: gl.getUniformLocation(p, "asp"), tam: gl.getUniformLocation(p, "tam") };
      dibujos.set(selector, d);
    }
    const { c, gl } = d, r = Math.min(devicePixelRatio || 1, 1.75);
    if (c.width !== Math.round(c.clientWidth * r)) { c.width = Math.round(c.clientWidth * r); c.height = Math.round(c.clientHeight * r); }
    gl.viewport(0, 0, c.width, c.height);
    gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
    gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
    gl.useProgram(d.p); gl.bindVertexArray(d.vao);
    const mem = new Uint8Array(memoria.buffer);
    listas.forEach((dir, b) => { gl.bindBuffer(gl.ARRAY_BUFFER, d.bufs[b]); gl.bufferSubData(gl.ARRAY_BUFFER, 0, mem, dir, n * 8); });
    gl.uniform1f(d.asp, c.width / c.height); gl.uniform1f(d.tam, 21 * r);
    gl.drawArrays(gl.POINTS, 0, n);
  }

  // Paquetes npm: extern "npm:paquete" funcion f(...) los importa solos.
  // Node.js: desde node_modules (npm install paquete). Navegador: el
  // empaquetador o el import map si lo resuelven; si no, desde esm.sh.
  const npm = {};
  for (const [modulo] of EXTERNAS) {
    if (!modulo.startsWith("npm:") || npm[modulo] || (opciones.modulos || {})[modulo]) continue;
    const paquete = modulo.slice(4);
    try {
      npm[modulo] = await import(paquete);
    } catch (e) {
      if (ES_NODE) throw new Error(`C-Forge: falta el paquete npm "${paquete}" (npm install ${paquete})`);
      npm[modulo] = await import("https://esm.sh/" + paquete);
    }
  }

  // Externas: módulo (biblioteca del extern) → nombre → función de JavaScript.
  const importaciones = { cf: { sys } };
  for (const [modulo, nombre, tipos, resultado] of EXTERNAS) {
    let fuente = modulo === "js" ? js : modulo === "navegador" ? NAVEGADOR : (opciones.modulos || {})[modulo] || npm[modulo] || {};
    // Paquetes CommonJS (lodash…): las funciones viven en default.
    if (fuente[nombre] === undefined && fuente.default && typeof fuente.default[nombre] === "function") fuente = fuente.default;
    const f = fuente[nombre] !== undefined ? fuente[nombre] : globalThis[nombre];
    if (typeof f !== "function") {
      // Biblioteca nativa (SDL2, sqlite3…) que no existe en la web: solo
      // falla si el programa la llama de verdad.
      (importaciones[modulo] ||= {})[nombre] = () => { throw new Error(`C-Forge: la función externa ${modulo}.${nombre} no está disponible en WebAssembly`); };
      continue;
    }
    (importaciones[modulo] ||= {})[nombre] = (...args) => {
      const valores = args.map((v, k) => {
        const t = tipos[k];
        if (t === 1) return bitsANumero(v);
        if (t === 2) return v === 0n ? null : cadena(Number(v));
        if (t === 3) return v !== 0n;
        if (t === 4) return null;
        return Number(BigInt.asIntN(64, v));
      });
      const r = f(...valores);
      if (resultado === 1) return numeroABits(Number(r));
      if (resultado === 2) return r == null ? 0n : textoEnMemoria(r);
      if (resultado === 3) return r ? 1n : 0n;
      if (resultado === 4) return 0n;
      return BigInt(Math.trunc(Number(r) || 0));
    };
  }

  const { instance } = await WebAssembly.instantiate(bytes, importaciones);
  memoria = instance.exports.memory;
  ejecutar = instance.exports.ejecutar;
  const fin = instance.exports.cf_fin.value;

  // Pila (8 MiB) tras datos y globales, con argc/argv/envp como en Linux;
  // después la reserva de textos y el monticulo (mmap).
  const tope = Math.ceil((fin + PILA) / 16) * 16;
  reservaTextos = tope;
  monticulo = Math.ceil((tope + RESERVA) / 65536) * 65536;
  crecer(monticulo);
  const args = ["programa", ...argumentos.map(String)];
  let p = tope - 16;
  const punteros = [];
  for (const a of args) {
    const b = enc.encode(a + "\0"); p -= b.length; u8().set(b, p); punteros.push(p);
  }
  p = Math.floor(p / 16) * 16 - 8 * (args.length + 4);
  p = Math.floor(p / 16) * 16;
  const d = dv();
  d.setBigInt64(p, BigInt(args.length), true);
  punteros.forEach((q, k) => d.setBigInt64(p + 8 + 8 * k, BigInt(q), true));
  d.setBigInt64(p + 8 + 8 * args.length, 0n, true);
  d.setBigInt64(p + 16 + 8 * args.length, 0n, true);
  pilaInicial = BigInt(p);

  // Llama a una función de C-Forge del programa con un entero (o nada).
  function llamarFuncion(nombre, entero = 0) {
    const dir = FUNCIONES[nombre];
    if (dir === undefined) throw new Error("C-Forge: no existe la función " + nombre);
    const r = ejecutar(BigInt(dir), BigInt(entero) * 2n + 1n, pilaInicial - 4096n);
    return (r & 1n) === 1n ? Number(BigInt.asIntN(64, r) >> 1n) : r;
  }
  let codigo = 0;
  programa = { llamar: (...a) => llamarFuncion(...a) };
  try { ejecutar(0n, 0n, pilaInicial); }
  catch (e) { if (e instanceof Salida) codigo = e.codigo; else throw e; }

  Object.assign(programa, { codigo, memoria, funciones: Object.keys(FUNCIONES) });
  return programa;
}

// node app.mjs [argumentos]: ejecuta el programa y sale con su código.
if (ES_NODE && process.argv[1] && import.meta.url === (await import("node:url")).pathToFileURL(process.argv[1]).href) {
  try {
    const p = await iniciar({ argumentos: process.argv.slice(2), web: false });
    process.exitCode = p.codigo;
  } catch (e) {
    if (e instanceof Salida) process.exitCode = e.codigo; else { console.error(e); process.exitCode = 1; }
  }
}
