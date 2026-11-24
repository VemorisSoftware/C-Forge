//! Crate de ejemplo para las pruebas de interoperabilidad: structs con
//! métodos, campos públicos, Result, Option, Vec, String, pánicos y un
//! módulo público. No sabe nada de C-Forge.
use std::fmt;

#[derive(Debug, Clone, PartialEq)]
pub struct Producto {
    pub nombre: String,
    pub precio: f64,
    pub stock: u32,
}

impl Producto {
    pub fn new(nombre: &str, precio: f64, stock: u32) -> Producto {
        Producto { nombre: nombre.to_string(), precio, stock }
    }
    pub fn total(&self) -> f64 { self.precio * self.stock as f64 }
    pub fn vender(&mut self, n: u32) -> Result<u32, String> {
        if n > self.stock { return Err(format!("solo quedan {}", self.stock)); }
        self.stock -= n;
        Ok(self.stock)
    }
    pub fn con_descuento(self, pct: f64) -> Producto { Producto { precio: self.precio * (1.0 - pct / 100.0), ..self } }
}

impl fmt::Display for Producto {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "{} (${:.2} × {})", self.nombre, self.precio, self.stock) }
}

#[derive(Debug, Default)]
pub struct Bodega { productos: Vec<Producto> }

impl Bodega {
    pub fn new() -> Self { Bodega::default() }
    pub fn agregar(&mut self, p: Producto) { self.productos.push(p); }
    pub fn buscar(&self, nombre: &str) -> Option<&Producto> { self.productos.iter().find(|p| p.nombre == nombre) }
    pub fn nombres(&self) -> Vec<String> { self.productos.iter().map(|p| p.nombre.clone()).collect() }
    pub fn precios(&self) -> Vec<f64> { self.productos.iter().map(|p| p.precio).collect() }
    pub fn valor_total(&self) -> f64 { self.productos.iter().map(|p| p.total()).sum() }
    pub fn len(&self) -> usize { self.productos.len() }
}

pub fn suma(v: &[i64]) -> i64 { v.iter().sum() }
pub fn promedio(v: Vec<f64>) -> Option<String> { if v.is_empty() { None } else { Some(format!("{:.3}", v.iter().sum::<f64>() / v.len() as f64)) } }
pub fn mayusculas(partes: &[String]) -> Vec<String> { partes.iter().map(|s| s.to_uppercase()).collect() }
pub fn primera_letra(t: &str) -> char { t.chars().next().unwrap_or('?') }
pub fn dividir(a: i32, b: i32) -> i32 { if b == 0 { panic!("división por cero") } a / b }
pub fn es_primo(n: u64) -> bool { n > 1 && (2..).take_while(|d| d * d <= n).all(|d| n % d != 0) }
pub fn identidad<T>(x: T) -> T { x }

pub mod texto {
    pub fn invertir(t: &str) -> String { t.chars().rev().collect() }
}
