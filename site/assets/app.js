// c-forge.org — interacciones mínimas, sin dependencias.
(function () {
  "use strict";
  document.documentElement.classList.add("js");
  var sinMovimiento = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // Aparición al hacer scroll
  var revelar = document.querySelectorAll(".r");
  if ("IntersectionObserver" in window && !sinMovimiento) {
    var io = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add("on"); io.unobserve(e.target); }
      });
    }, { threshold: 0.05, rootMargin: "0px 0px -30px 0px" });
    revelar.forEach(function (el, i) { el.style.transitionDelay = (i % 5) * 0.07 + "s"; io.observe(el); });
    setTimeout(function () { revelar.forEach(function (e) { e.classList.add("on"); }); }, 6000);
  } else {
    revelar.forEach(function (e) { e.classList.add("on"); });
  }

  // Terminal animada: las líneas vienen del HTML (data-secuencia)
  var term = document.getElementById("terminal");
  if (term) {
    var pasos = JSON.parse(term.getAttribute("data-secuencia"));
    var linea = function (clase, texto) {
      var d = document.createElement("div");
      if (clase) { var s = document.createElement("span"); s.className = clase; s.textContent = texto; d.appendChild(s); }
      else d.textContent = texto || " ";
      term.appendChild(d); return d;
    };
    var cursor = function () {
      var d = document.createElement("div");
      d.innerHTML = '<span class="tp">$ </span><span class="cursor"></span>';
      term.appendChild(d);
    };
    if (sinMovimiento) {
      pasos.forEach(function (p) { if (p[0] === "$") { var d = linea("tp", "$ "); d.appendChild(document.createTextNode(p[1])); } else linea(p[0], p[1]); });
      cursor();
    } else {
      var i = 0;
      var siguiente = function () {
        if (i >= pasos.length) { cursor(); return; }
        var p = pasos[i++];
        if (p[0] === "$") {
          var d = linea("tp", "$ "); var t = document.createElement("span"); d.appendChild(t);
          var k = 0;
          var teclear = function () {
            if (k >= p[1].length) { setTimeout(siguiente, 450); return; }
            t.textContent += p[1][k++];
            var demora = 38 * (0.6 + Math.random() * 0.8);
            setTimeout(teclear, p[1][k - 1] === " " ? demora * 1.5 : demora);
          };
          teclear();
        } else {
          linea(p[0], p[1]); setTimeout(siguiente, p[0] === "" ? 60 : 220);
        }
      };
      setTimeout(siguiente, 400);
    }
  }

  // Copiar comandos
  document.addEventListener("click", function (e) {
    var boton = e.target.closest("[data-copiar]");
    if (!boton) return;
    var texto = boton.getAttribute("data-copiar");
    var listo = function () {
      boton.setAttribute("data-copiado", "");
      boton.textContent = "Copiado";
      setTimeout(function () { boton.removeAttribute("data-copiado"); boton.textContent = "Copiar"; }, 1600);
    };
    if (navigator.clipboard) navigator.clipboard.writeText(texto).then(listo, function () {});
  });

  // Pestañas accesibles
  document.querySelectorAll("[role=tablist]").forEach(function (lista) {
    var pestanas = Array.prototype.slice.call(lista.querySelectorAll("[role=tab]"));
    function activar(p) {
      pestanas.forEach(function (o) {
        var sel = o === p;
        o.setAttribute("aria-selected", sel ? "true" : "false");
        o.tabIndex = sel ? 0 : -1;
        document.getElementById(o.getAttribute("aria-controls")).hidden = !sel;
      });
    }
    pestanas.forEach(function (p, i) {
      p.addEventListener("click", function () { activar(p); });
      p.addEventListener("keydown", function (e) {
        var d = e.key === "ArrowRight" ? 1 : e.key === "ArrowLeft" ? -1 : 0;
        if (!d) return;
        var sig = pestanas[(i + d + pestanas.length) % pestanas.length];
        activar(sig); sig.focus();
      });
    });
    // Instalar: abrir la pestaña del sistema del visitante
    if (lista.hasAttribute("data-detectar-so")) {
      var ua = navigator.userAgent;
      var so = /Windows/.test(ua) ? "windows" : /Mac/.test(ua) ? "macos" : /Linux/.test(ua) ? "linux" : null;
      var p = so && lista.querySelector('[data-so="' + so + '"]');
      if (p) activar(p);
    }
  });

  // Menú móvil
  var nav = document.querySelector(".nav");
  var menu = document.querySelector(".menu-boton");
  if (nav && menu) {
    menu.addEventListener("click", function () {
      var abierto = nav.toggleAttribute("data-abierto");
      menu.setAttribute("aria-expanded", abierto ? "true" : "false");
    });
    nav.addEventListener("click", function (e) {
      if (e.target.closest(".nav-enlaces a")) { nav.removeAttribute("data-abierto"); menu.setAttribute("aria-expanded", "false"); }
    });
  }

  // Índice de Aprende: resaltar la sección visible
  var enlaces = document.querySelectorAll(".docs-indice a");
  if (enlaces.length && "IntersectionObserver" in window) {
    var porId = {};
    enlaces.forEach(function (a) { porId[a.getAttribute("href").slice(1)] = a; });
    var obs = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (en) {
        if (!en.isIntersecting) return;
        enlaces.forEach(function (a) { a.classList.remove("activo"); });
        var a = porId[en.target.id];
        if (a) a.classList.add("activo");
      });
    }, { rootMargin: "-20% 0px -70% 0px" });
    document.querySelectorAll(".docs-contenido section[id]").forEach(function (s) { obs.observe(s); });
  }
})();
