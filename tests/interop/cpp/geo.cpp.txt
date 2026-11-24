#include "geo.hpp"
#include <cmath>
#include <sstream>
namespace geo {
Punto::Punto() : x_(0), y_(0) {}
Punto::Punto(double x, double y) : x_(x), y_(y) {}
double Punto::x() const { return x_; }
double Punto::y() const { return y_; }
double Punto::distancia(const Punto& o) const { return std::hypot(x_ - o.x_, y_ - o.y_); }
void Punto::mover(double dx, double dy) { x_ += dx; y_ += dy; }
std::string Punto::texto() const { std::ostringstream s; s << "(" << x_ << ", " << y_ << ")"; return s.str(); }
Punto Punto::sumar(const Punto& o) const { return Punto(x_ + o.x_, y_ + o.y_); }
Punto Punto::origen() { return Punto(); }
Poligono::Poligono(const std::string& n) : nombre_(n) {}
void Poligono::agregar(const Punto& p) { puntos_.push_back(p); }
int Poligono::lados() const { return (int)puntos_.size(); }
double Poligono::perimetro() const { double s = 0; for (size_t i = 0; i < puntos_.size(); i++) s += puntos_[i].distancia(puntos_[(i + 1) % puntos_.size()]); return s; }
std::vector<double> Poligono::xs() const { std::vector<double> v; for (auto& p : puntos_) v.push_back(p.x()); return v; }
const std::string& Poligono::nombre() const { return nombre_; }
Punto& Poligono::vertice(int i) { if (i < 0 || i >= (int)puntos_.size()) throw std::out_of_range("vértice fuera de rango"); return puntos_[i]; }
double area_circulo(double r) { return M_PI * r * r; }
int sumar(int a, int b) { return a + b; }
double sumar(double a, double b) { return a + b + 0.5; }
long long factorial(int n) { return n <= 1 ? 1 : n * factorial(n - 1); }
float mitad(float x) { return x / 2; }
bool es_par(long long n) { return n % 2 == 0; }
std::string saludar(const std::string& n) { return "¡Hola, " + n + "!"; }
double promedio(const std::vector<double>& v) { if (v.empty()) throw std::invalid_argument("lista vacía"); double s = 0; for (double x : v) s += x; return s / v.size(); }
std::vector<int> rango(int a, int b) { std::vector<int> v; for (int i = a; i < b; i++) v.push_back(i); return v; }
std::vector<std::string> partir(const std::string& t, char sep) { std::vector<std::string> v; std::string x; for (char c : t) { if (c == sep) { v.push_back(x); x.clear(); } else x += c; } v.push_back(x); return v; }
std::string unir(const std::vector<std::string>& p, const std::string& sep) { std::string r; for (size_t i = 0; i < p.size(); i++) { if (i) r += sep; r += p[i]; } return r; }
double convertir(double v, Unidad de, Unidad a) { if (de == a) return v; return de == Unidad::Metros ? v * 3.28084 : v / 3.28084; }
double raiz_segura(double x) { if (x < 0) throw std::domain_error("raíz de un negativo"); return std::sqrt(x); }
void ignorar(int (*)(int)) {}
}
