/* Cabecera de prueba para cforge bindgen. */
#ifndef EJEMPLO_H
#define EJEMPLO_H
#include "ejemplo_tipos.h"
#define EJ_API
#define EJ_VERSION 3
#define EJ_MASCARA 0x10UL
#define EJ_DESPLAZADO (1 << 4)
#define EJ_NOMBRE "ejemplo"
#ifdef __cplusplus
extern "C" {
#endif
typedef enum { EJ_ROJO, EJ_VERDE = 5, EJ_AZUL } ej_color;
typedef struct ej_ctx ej_ctx;
typedef int (*ej_cb)(void *dato, int n);
EJ_API size_t strlen(const char *s);
EJ_API int abs(int x);
EJ_API ej_ctx *ej_abrir(const char *ruta, ej_color c);
EJ_API void ej_cerrar(ej_ctx *ctx);
EJ_API double ej_media(const double *v, ej_tam n);
EJ_API int ej_registrar(ej_ctx *ctx, ej_cb cb, void *dato);
EJ_API int ej_imprimir(const char *fmt, ...);
EJ_API float ej_flotante(float x);
static inline int ej_doble(int x) { return x * 2; }
#ifdef __cplusplus
}
#endif
#endif
