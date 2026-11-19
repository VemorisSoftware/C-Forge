// Valida módulos .wasm con el validador del motor (V8 sigue la
// especificación completa: tipos, pila, secciones e índices) y revisa la
// estructura: cabecera, secciones en orden y tamaños coherentes.
import { readFileSync } from "node:fs";

const ORDEN = [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 10, 11];
let fallas = 0;
for (const ruta of process.argv.slice(2)) {
  const b = readFileSync(ruta);
  const problemas = [];
  if (b.length < 8) { fallas++; console.error(`✗ ${ruta}: archivo demasiado corto`); continue; }
  if (b.readUInt32LE(0) !== 0x6d736100) problemas.push("sin la firma \\0asm");
  if (b.readUInt32LE(4) !== 1) problemas.push("versión distinta de 1");
  let p = 8, ultimo = -1;
  const leb = () => { let r = 0, s = 0, x; do { x = b[p++]; r |= (x & 127) << s; s += 7; } while (x & 128); return r >>> 0; };
  while (p < b.length && problemas.length === 0) {
    const id = b[p++];
    const largo = leb();
    if (p + largo > b.length) { problemas.push(`sección ${id} truncada`); break; }
    if (id !== 0) {
      const pos = ORDEN.indexOf(id);
      if (pos < 0) problemas.push(`sección desconocida ${id}`);
      else if (pos <= ultimo) problemas.push(`sección ${id} fuera de orden`);
      ultimo = pos;
    }
    p += largo;
  }
  if (!WebAssembly.validate(b)) problemas.push("WebAssembly.validate lo rechaza");
  else {
    try { new WebAssembly.Module(b); } catch (e) { problemas.push(String(e.message || e)); }
  }
  if (problemas.length) { fallas++; console.error(`✗ ${ruta}: ${problemas.join("; ")}`); }
}
process.exit(fallas ? 1 : 0);
