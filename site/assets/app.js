// c-forge.org — interacciones mínimas, sin dependencias.
(function () {
  "use strict";

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
