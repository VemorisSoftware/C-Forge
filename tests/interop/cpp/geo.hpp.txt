// Librería C++ de ejemplo para las pruebas de interoperabilidad: clases,
// sobrecargas, std::string, std::vector, enums, métodos estáticos y
// excepciones. No sabe nada de C-Forge.
#pragma once
#include <string>
#include <vector>
#include <stdexcept>

namespace geo {

enum class Unidad { Metros = 0, Pies = 1 };

class Punto {
public:
    Punto();
    Punto(double x, double y);
    double x() const;
    double y() const;
    double distancia(const Punto& otro) const;
    void mover(double dx, double dy);
    std::string texto() const;
    Punto sumar(const Punto& otro) const;
    static Punto origen();
private:
    double x_, y_;
};

class Poligono {
public:
    explicit Poligono(const std::string& nombre);
    void agregar(const Punto& p);
    int lados() const;
    double perimetro() const;
    std::vector<double> xs() const;
    const std::string& nombre() const;
    Punto& vertice(int i);
private:
    std::string nombre_;
    std::vector<Punto> puntos_;
};

double area_circulo(double r);
int sumar(int a, int b);
double sumar(double a, double b);
long long factorial(int n);
float mitad(float x);
bool es_par(long long n);
std::string saludar(const std::string& nombre);
double promedio(const std::vector<double>& v);
std::vector<int> rango(int desde, int hasta);
std::vector<std::string> partir(const std::string& texto, char sep);
std::string unir(const std::vector<std::string>& partes, const std::string& sep);
double convertir(double valor, Unidad de, Unidad a);
double raiz_segura(double x);
void ignorar(int (*callback)(int));
template <class T> T maximo(T a, T b) { return a > b ? a : b; }

}
