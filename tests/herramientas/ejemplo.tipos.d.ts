/** Tipos de prueba para cforge bindgen (TypeScript). */
export type Opciones = { exacto?: boolean };
export declare function saludar(nombre: string, veces?: number): string;
export function sumar(a: number, b: number): number;
declare function activo(): boolean;
export function registrar(mensaje: string | number): void;
export function opcional(texto: string, opciones?: Opciones): string;
export function identidad<T>(x: T): T;
export function juntar(...partes: string[]): string;
export function objeto(o: { a: number }): string;
export default function principal(x: string): string;
