// Ejecuta tests/wasm/interop.cfv compilado a WebAssembly: externas, llamadas
// desde JavaScript, tareas y errores capturables del runtime.
import { iniciar } from "./salida/interop.mjs";
const lineas = [], errores = [];
const programa = await iniciar({
  web: true,
  escribir: (fd, t) => (fd === 2 ? errores : lineas).push(t),
  js: { doble: (x) => x * 2.5, saludo: (n) => "hola " + n + " ñ", avisar: (c, ok) => lineas.push(`avisar ${c} ${ok}\n`) },
}).catch((e) => { lineas.push("excepción: " + e.message + "\n"); return null; });
lineas.push(`cuadrado ${programa.llamar("cuadrado", 12)}\n`);
lineas.push(`contar ${programa.llamar("contar", 1000)}\n`);
lineas.push(`falla ${programa.llamar("falla", 1)}\n`);
try { programa.llamar("falla", 9); } catch (e) { lineas.push(`salida ${e.codigo}: ${errores.join("")}`); }
const salida = lineas.join("");
const esperado = "52.5\nhola C-Forge ñ\navisar 7 true\n42\ncuadrado 144\ncontar 499500\nfalla 2\nsalida 1: [C-Forge] índice de lista inválido\n";
if (salida !== esperado) { console.log(salida); console.log("  ✗ wasm: interop"); process.exit(1); }
console.log("  ✓ wasm: extern \"js\", llamadas desde JavaScript, tareas y errores");
