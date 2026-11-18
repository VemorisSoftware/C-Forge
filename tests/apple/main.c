// tests/apple/main.c — usa la biblioteca de C-Forge (cforge build --lib) desde C.
#include <stdio.h>
#include "calculos.h"

int main(void) {
    printf("%g\n", doble(21.5));
    printf("%lld\n", (long long)sumar(40, 2));
    printf("%s\n", saludo("Xcode"));
    printf("%s\n", saludo("Swift"));
    printf("%d %d\n", es_par(10), es_par(7));
    return 0;
}
