// c-forge.org — tema claro u oscuro antes de pintar la página. Sin elección
// guardada, sigue al sistema (prefers-color-scheme).
(function () {
  try {
    var t = localStorage.getItem("cforge-tema");
    if (t === "claro" || t === "oscuro") document.documentElement.setAttribute("data-tema", t);
  } catch (e) {}
})();
