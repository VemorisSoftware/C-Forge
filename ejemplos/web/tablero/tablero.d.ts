// Generado por cforge build --target wasm.
export interface ProgramaCForge {
  codigo: number;
  memoria: WebAssembly.Memory;
  funciones: string[];
  llamar(nombre: string, entero?: number): number | bigint;
}
export interface OpcionesCForge {
  js?: Record<string, (...args: any[]) => any>;
  modulos?: Record<string, Record<string, (...args: any[]) => any>>;
  argumentos?: string[];
  web?: boolean;
  wasm?: BufferSource;
  escribir?: (fd: number, texto: string) => void;
}
export function iniciar(opciones?: OpcionesCForge): Promise<ProgramaCForge>;
