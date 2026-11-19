// c-forge.org — "La forja": partículas en WebGL2 que siguen el scroll y el mouse.
// Sin dependencias. La física de las partículas está escrita en C-Forge
// (site/forja/forja.cfv) y compilada a WebAssembly (assets/forja/forja.wasm);
// este archivo solo dibuja. Mientras el módulo carga, o si el navegador no
// puede usarlo, una versión en JavaScript hace lo mismo.
(function () {
  "use strict";
  var lienzo = document.getElementById("forja");
  if (!lienzo) return;
  var gl = lienzo.getContext("webgl2", { alpha: true, antialias: false, premultipliedAlpha: false, powerPreference: "high-performance" });
  if (!gl) { lienzo.remove(); return; }
  document.documentElement.classList.add("con-forja");
  var quieto = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // ── Cantidad de partículas según la pantalla ──
  var movil = Math.min(window.innerWidth, window.innerHeight) < 700;
  var N = movil ? 9000 : 26000;
  var pos = new Float32Array(N * 3), vel = new Float32Array(N * 3), salida = new Float32Array(N * 4);
  var esfera = new Float32Array(N * 3), malla = new Float32Array(N * 2), letras = new Float32Array(N * 3), galaxia = new Float32Array(N * 3);

  // Azar reproducible (mismo dibujo en cada visita).
  var semilla = 1234567;
  function azar() { semilla = (semilla * 1103515245 + 12345) & 0x7fffffff; return semilla / 0x7fffffff; }
  function gauss() { return Math.sqrt(-2 * Math.log(azar() + 1e-9)) * Math.cos(6.2831853 * azar()); }

  // 0 · Núcleo: esfera de Fibonacci con algo de grosor.
  var oro = Math.PI * (3 - Math.sqrt(5));
  for (var i = 0; i < N; i++) {
    var y = 1 - (i / (N - 1)) * 2, r = Math.sqrt(1 - y * y), th = oro * i;
    var capa = 1 + gauss() * 0.06 + (azar() < 0.12 ? azar() * 0.6 : 0);
    esfera[i * 3] = Math.cos(th) * r * capa; esfera[i * 3 + 1] = y * capa; esfera[i * 3 + 2] = Math.sin(th) * r * capa;
  }
  // 1 · Malla ondulada (u, v en -1..1).
  var lado = Math.ceil(Math.sqrt(N));
  for (i = 0; i < N; i++) { malla[i * 2] = (i % lado) / (lado - 1) * 2 - 1; malla[i * 2 + 1] = Math.floor(i / lado) / (lado - 1) * 2 - 1; }
  // 2 · "CF" muestreado de un texto dibujado en un canvas 2D.
  (function () {
    var c = document.createElement("canvas"), w = 520, h = 240; c.width = w; c.height = h;
    var x = c.getContext("2d"); x.fillStyle = "#fff"; x.font = "900 210px -apple-system, Inter, Segoe UI, sans-serif";
    x.textAlign = "center"; x.textBaseline = "middle"; x.fillText("CF", w / 2, h / 2 + 10);
    var d = x.getImageData(0, 0, w, h).data, puntos = [];
    for (var py = 0; py < h; py += 2) for (var px = 0; px < w; px += 2) if (d[(py * w + px) * 4 + 3] > 128) puntos.push(px, py);
    var n = puntos.length / 2 || 1;
    for (var k = 0; k < N; k++) {
      var j = Math.floor(azar() * n) * 2;
      letras[k * 3] = ((puntos[j] || w / 2) - w / 2) / w * 5.6 + (azar() - 0.5) * 0.02;
      letras[k * 3 + 1] = -((puntos[j + 1] || h / 2) - h / 2) / w * 5.6;
      letras[k * 3 + 2] = gauss() * 0.12;
    }
  })();
  // 3 · Galaxia espiral de dos brazos.
  for (i = 0; i < N; i++) {
    var rr = Math.pow(azar(), 0.7) * 3.4, brazo = (i & 1) * Math.PI;
    galaxia[i * 3] = rr; galaxia[i * 3 + 1] = brazo + rr * 1.9 + gauss() * 0.28 / (0.4 + rr * 0.3); galaxia[i * 3 + 2] = gauss() * 0.07 * (3.6 - rr);
  }
  for (i = 0; i < N * 3; i++) pos[i] = esfera[i] * 4 + gauss() * 0.4;

  // ── Cámara y escenario ──
  var FOV = 50 * Math.PI / 180, CAM = 6, ancho = 1, alto = 1, dpr = 1;
  function aMundo(sx, sy) {
    var h = Math.tan(FOV / 2) * CAM;
    return [(sx / ancho * 2 - 1) * h * (ancho / alto), -(sy / alto * 2 - 1) * h];
  }
  function ajustar() {
    dpr = Math.min(window.devicePixelRatio || 1, 1.75);
    ancho = window.innerWidth; alto = window.innerHeight;
    lienzo.width = Math.round(ancho * dpr); lienzo.height = Math.round(alto * dpr);
    gl.viewport(0, 0, lienzo.width, lienzo.height);
  }
  window.addEventListener("resize", ajustar); ajustar();

  var raton = { x: -1e4, y: -1e4, mx: 0, my: 0, activo: 0 };
  window.addEventListener("pointermove", function (e) {
    var m = aMundo(e.clientX, e.clientY); raton.x = m[0]; raton.y = m[1];
    raton.mx = e.clientX / ancho * 2 - 1; raton.my = e.clientY / alto * 2 - 1; raton.activo = 1;
  }, { passive: true });
  document.addEventListener("pointerleave", function () { raton.activo = 0; });

  // Centro del núcleo: detrás de la mascota del hero.
  var mascota = document.querySelector(".mascota");
  function centroNucleo() {
    if (!mascota) return [1.8, 0.6];
    var b = mascota.getBoundingClientRect();
    return aMundo(b.left + b.width / 2, b.top + b.height / 2);
  }
  function progreso() {
    var max = document.documentElement.scrollHeight - alto;
    return max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0;
  }
  function suave(x) { x = Math.min(1, Math.max(0, x)); return x * x * (3 - 2 * x); }

  // ── Simulación (JavaScript; la de C-Forge/WebAssembly tiene la misma firma) ──
  // etapa: 0..3 (núcleo → malla → CF → galaxia), mezcla dentro de la etapa.
  function objetivo(forma, i, t, c, o) {
    var k3 = i * 3;
    if (forma === 0) {
      var a = t * 0.25, ca = Math.cos(a), sa = Math.sin(a);
      var x = esfera[k3], y = esfera[k3 + 1], z = esfera[k3 + 2];
      var ondula = 0.9 + 0.08 * Math.sin(x * 3.1 + t * 1.3) * Math.cos(y * 2.7 - t);
      o[0] = c[0] + (x * ca - z * sa) * ondula; o[1] = c[1] + y * ondula; o[2] = (x * sa + z * ca) * ondula;
    } else if (forma === 1) {
      var u = malla[i * 2], v = malla[i * 2 + 1];
      o[0] = u * 6.5; o[2] = v * 3 - 1.2;
      o[1] = -1.1 + 0.42 * Math.sin(u * 3.2 + t * 0.9) * Math.cos(v * 2.3 + t * 0.6) + 0.18 * Math.sin(u * 7 - t * 1.4);
    } else if (forma === 2) {
      var resp = 1 + 0.03 * Math.sin(t * 1.6 + letras[k3] * 2);
      o[0] = letras[k3] * resp; o[1] = letras[k3 + 1] * resp + 0.2; o[2] = letras[k3 + 2] + 0.08 * Math.sin(t + letras[k3 + 1] * 4);
    } else {
      var rg = galaxia[k3], ag = galaxia[k3 + 1] + t * 0.08 / (0.3 + rg * 0.25);
      var gx = Math.cos(ag) * rg, gz = Math.sin(ag) * rg;
      o[0] = gx; o[1] = gz * 0.42 + galaxia[k3 + 2] - 0.2; o[2] = gz * 0.9 - galaxia[k3 + 2];
    }
  }
  var oa = [0, 0, 0], ob = [0, 0, 0];
  function simularJS(t, etapa, mezcla, c) {
    var fa = Math.min(3, Math.floor(etapa)), fb = Math.min(3, fa + 1);
    var rx = raton.x, ry = raton.y, fuerza = raton.activo ? 1 : 0;
    for (var i = 0; i < N; i++) {
      objetivo(fa, i, t, c, oa);
      if (mezcla > 0.001) { objetivo(fb, i, t, c, ob); oa[0] += (ob[0] - oa[0]) * mezcla; oa[1] += (ob[1] - oa[1]) * mezcla; oa[2] += (ob[2] - oa[2]) * mezcla; }
      var k = i * 3, px = pos[k], py = pos[k + 1], pz = pos[k + 2];
      var vx = vel[k] + (oa[0] - px) * 0.035, vy = vel[k + 1] + (oa[1] - py) * 0.035, vz = vel[k + 2] + (oa[2] - pz) * 0.035;
      // El mouse empuja las partículas cercanas (en el plano de la pantalla).
      var dx = px - rx, dy = py - ry, d2 = dx * dx + dy * dy;
      if (fuerza && d2 < 1.6) { var f = 0.06 * Math.exp(-d2 * 3) / Math.sqrt(d2 + 0.02); vx += dx * f; vy += dy * f; vz += 0.02 * f; }
      vx *= 0.88; vy *= 0.88; vz *= 0.88;
      pos[k] = px + vx; pos[k + 1] = py + vy; pos[k + 2] = pz + vz;
      vel[k] = vx; vel[k + 1] = vy; vel[k + 2] = vz;
      var o = i * 4; salida[o] = pos[k]; salida[o + 1] = pos[k + 1]; salida[o + 2] = pos[k + 2];
      salida[o + 3] = Math.min(1, Math.sqrt(vx * vx + vy * vy + vz * vz) * 9);
    }
    return salida;
  }
  var api = window.CForgeForja = { N: N, pos: pos, vel: vel, salida: salida, raton: raton, simular: simularJS, motor: "JavaScript" };

  // ── Dibujo ──
  function sombreador(tipo, fuente) {
    var s = gl.createShader(tipo); gl.shaderSource(s, fuente); gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(s));
    return s;
  }
  var prog = gl.createProgram();
  gl.attachShader(prog, sombreador(gl.VERTEX_SHADER, [
    "#version 300 es",
    "layout(location=0) in vec4 p;",
    "uniform vec2 u_aspecto; uniform float u_tam, u_tiempo; uniform vec2 u_parallax;",
    "out float v_calor; out float v_prof;",
    "void main(){",
    "  vec3 q = p.xyz;",
    "  float a = u_parallax.x * 0.12, b = u_parallax.y * 0.08;",
    "  q = vec3(q.x*cos(a) + q.z*sin(a), q.y, -q.x*sin(a) + q.z*cos(a));",
    "  q = vec3(q.x, q.y*cos(b) - q.z*sin(b), q.y*sin(b) + q.z*cos(b));",
    "  float z = 6.0 - q.z;",
    "  float f = 1.0 / tan(radians(25.0));",
    "  gl_Position = vec4(q.x * f / u_aspecto.x, q.y * f, (z - 0.1) / 40.0 * z, z);",
    "  gl_PointSize = u_tam * (1.0 + p.w * 1.6) / z;",
    "  v_calor = p.w; v_prof = clamp((z - 3.0) / 6.0, 0.0, 1.0);",
    "}"].join("\n")));
  gl.attachShader(prog, sombreador(gl.FRAGMENT_SHADER, [
    "#version 300 es",
    "precision mediump float;",
    "in float v_calor; in float v_prof; uniform float u_brillo; out vec4 color;",
    "void main(){",
    "  vec2 d = gl_PointCoord - 0.5; float r = dot(d, d);",
    "  float a = exp(-r * 16.0);",
    "  vec3 brasa = vec3(1.0, 0.416, 0.196);",
    "  vec3 c = mix(brasa, vec3(1.0, 0.78, 0.35), smoothstep(0.15, 0.6, v_calor));",
    "  c = mix(c, vec3(1.0), smoothstep(0.6, 1.0, v_calor));",
    "  color = vec4(c, a * u_brillo * (1.0 - v_prof * 0.55));",
    "}"].join("\n")));
  gl.linkProgram(prog);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) { lienzo.remove(); return; }
  // Variante para C-Forge: lee las listas del módulo tal cual (enteros
  // etiquetados 2v + 1, en milésimas).
  var fuenteFrag = gl.getAttachedShaders(prog)[1];
  var progCF = gl.createProgram();
  gl.attachShader(progCF, sombreador(gl.VERTEX_SHADER, [
    "#version 300 es",
    "layout(location=1) in float ex; layout(location=2) in float ey; layout(location=3) in float ez; layout(location=4) in float ec;",
    "uniform vec2 u_aspecto; uniform float u_tam, u_tiempo; uniform vec2 u_parallax;",
    "out float v_calor; out float v_prof;",
    "void main(){",
    "  vec4 p = (vec4(ex, ey, ez, ec) - 1.0) * 0.0005;",
    "  vec3 q = p.xyz;",
    "  float a = u_parallax.x * 0.12, b = u_parallax.y * 0.08;",
    "  q = vec3(q.x*cos(a) + q.z*sin(a), q.y, -q.x*sin(a) + q.z*cos(a));",
    "  q = vec3(q.x, q.y*cos(b) - q.z*sin(b), q.y*sin(b) + q.z*cos(b));",
    "  float z = 6.0 - q.z;",
    "  float f = 1.0 / tan(radians(25.0));",
    "  gl_Position = vec4(q.x * f / u_aspecto.x, q.y * f, (z - 0.1) / 40.0 * z, z);",
    "  gl_PointSize = u_tam * (1.0 + p.w * 1.6) / z;",
    "  v_calor = p.w; v_prof = clamp((z - 3.0) / 6.0, 0.0, 1.0);",
    "}"].join("\n")));
  gl.attachShader(progCF, fuenteFrag);
  gl.linkProgram(progCF);
  var listaCF = null, bufCF = [], vaoJS = null, vaoCF = null;
  gl.useProgram(prog);
  vaoJS = gl.createVertexArray(); gl.bindVertexArray(vaoJS);
  var buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, salida.byteLength, gl.DYNAMIC_DRAW);
  gl.enableVertexAttribArray(0);
  gl.vertexAttribPointer(0, 4, gl.FLOAT, false, 0, 0);
  vaoCF = gl.createVertexArray(); gl.bindVertexArray(vaoCF);
  for (var b = 0; b < 4; b++) {
    bufCF.push(gl.createBuffer());
    gl.bindBuffer(gl.ARRAY_BUFFER, bufCF[b]);
    gl.bufferData(gl.ARRAY_BUFFER, N * 8, gl.DYNAMIC_DRAW);
    gl.enableVertexAttribArray(b + 1);
    // Los 32 bits bajos de cada entero de 64 bits (little endian).
    gl.vertexAttribPointer(b + 1, 1, gl.INT, false, 8, 0);
  }
  gl.bindVertexArray(null);
  gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
  function uniformes(p) {
    return { asp: gl.getUniformLocation(p, "u_aspecto"), tam: gl.getUniformLocation(p, "u_tam"), bri: gl.getUniformLocation(p, "u_brillo"),
             par: gl.getUniformLocation(p, "u_parallax"), t: gl.getUniformLocation(p, "u_tiempo") };
  }
  var uJS = uniformes(prog), uCF = gl.getProgramParameter(progCF, gl.LINK_STATUS) ? uniformes(progCF) : null;

  // ── Física en C-Forge (WebAssembly) ──
  var cf = null, entrada = [N, 0, 0, 0, 0, 0, 0, 0, 0];
  if (uCF && typeof WebAssembly === "object") {
    import("/assets/forja/forja.mjs").then(function (m) {
      return m.iniciar({ web: true, js: {
        forja_entrada: function (k) { return entrada[k]; },
        forja_listas: function (x, y, z, calor, n) { listaCF = [x, y, z, calor, n]; }
      } });
    }).then(function (programa) {
      if (!listaCF || listaCF[4] !== N) return;
      // Arranca desde donde iban las partículas de JavaScript.
      cf = programa;
      api.motor = "C-Forge → WebAssembly";
      var d = new DataView(cf.memoria.buffer);
      for (var i = 0; i < N; i++) for (var e = 0; e < 3; e++) d.setBigInt64(listaCF[e] + i * 8, BigInt(Math.round(pos[i * 3 + e] * 1000)) * 2n + 1n, true);
      var marca = document.createElement("a");
      marca.className = "forja-motor"; marca.href = "https://github.com/VemorisSoftware/C-Forge/blob/main/site/forja/forja.cfv";
      marca.rel = "noopener"; marca.textContent = "partículas: C-Forge → WebAssembly";
      document.body.appendChild(marca); api.marca = marca;
    }).catch(function (e) { api.errorCF = String(e); });
  }

  var t0 = performance.now(), visible = true, parallax = [0, 0], mediciones = [];
  document.addEventListener("visibilitychange", function () { visible = !document.hidden; if (visible) requestAnimationFrame(cuadro); });

  function cuadro(ahora) {
    if (!visible) return;
    var t = quieto ? 0 : (ahora - t0) / 1000;
    var p = progreso();
    // Núcleo (hero) → malla → CF → galaxia a lo largo de la página.
    var etapa = suave(p / 0.12) + suave((p - 0.25) / 0.2) + suave((p - 0.6) / 0.25);
    var mezcla = etapa - Math.floor(etapa);
    var inicio = performance.now(), u;
    var centro = centroNucleo();
    if (cf) {
      entrada[1] = Math.round(t * 1000); entrada[2] = Math.round(etapa * 1000); entrada[3] = Math.round(mezcla * 1024);
      entrada[4] = Math.round(centro[0] * 1000); entrada[5] = Math.round(centro[1] * 1000);
      entrada[6] = Math.round(raton.x * 1000); entrada[7] = Math.round(raton.y * 1000); entrada[8] = raton.activo;
      cf.llamar("forja_paso", 0);
      gl.useProgram(progCF); gl.bindVertexArray(vaoCF); u = uCF;
      var mem = new Uint8Array(cf.memoria.buffer);
      for (var b = 0; b < 4; b++) {
        gl.bindBuffer(gl.ARRAY_BUFFER, bufCF[b]);
        gl.bufferSubData(gl.ARRAY_BUFFER, 0, mem, listaCF[b], N * 8);
      }
    } else {
      var datos = api.simular(t, etapa, mezcla, centro);
      gl.useProgram(prog); gl.bindVertexArray(vaoJS); u = uJS;
      gl.bindBuffer(gl.ARRAY_BUFFER, buf);
      gl.bufferSubData(gl.ARRAY_BUFFER, 0, datos);
    }
    mediciones.push(performance.now() - inicio); if (mediciones.length > 60) mediciones.shift();
    api.msPorCuadro = mediciones.reduce(function (a, b) { return a + b; }, 0) / mediciones.length;
    if (api.marca && mediciones.length === 60 && Math.round(ahora) % 30 < 17) api.marca.textContent = "partículas: C-Forge → WebAssembly · " + api.msPorCuadro.toFixed(1) + " ms";
    parallax[0] += (raton.mx - parallax[0]) * 0.05; parallax[1] += (raton.my - parallax[1]) * 0.05;
    gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
    gl.uniform2f(u.asp, ancho / alto, 1);
    gl.uniform1f(u.tam, (movil ? 24 : 21) * dpr);
    // Más intenso en el hero; más tenue detrás del contenido.
    gl.uniform1f(u.bri, 0.75 - 0.3 * suave(p / 0.1) + 0.2 * suave((p - 0.85) / 0.15));
    gl.uniform2f(u.par, parallax[0], parallax[1]); gl.uniform1f(u.t, t);
    gl.drawArrays(gl.POINTS, 0, N);
    if (!quieto) requestAnimationFrame(cuadro);
  }
  if (quieto) {
    // Sin animación: varias iteraciones para asentar las partículas y un cuadro fijo.
    for (var it = 0; it < 120; it++) simularJS(0, 0, 0, centroNucleo());
    window.addEventListener("scroll", function () { requestAnimationFrame(cuadro); }, { passive: true });
  }
  requestAnimationFrame(cuadro);
})();
