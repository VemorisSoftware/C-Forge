// Programa de prueba: cuenta bytes por valor en un mapa hash y suma con un array.
typedef unsigned int u32;
typedef unsigned long long u64;
struct bpf_map_def { u32 type; u32 key_size; u32 value_size; u32 max_entries; u32 map_flags; };
#define SEC(n) __attribute__((section(n), used))
static void *(*bpf_map_lookup_elem)(void *map, const void *key) = (void *) 1;
static long (*bpf_map_update_elem)(void *map, const void *key, const void *value, u64 flags) = (void *) 2;
static long (*bpf_trace_printk)(const char *fmt, u32 fmt_size, ...) = (void *) 6;
struct bpf_map_def SEC("maps") cuentas = { .type = 1, .key_size = 4, .value_size = 8, .max_entries = 64 };
struct bpf_map_def SEC("maps") total = { .type = 2, .key_size = 4, .value_size = 8, .max_entries = 1 };
struct ctx { u32 n; unsigned char datos[16]; };
SEC("socket") int contar(struct ctx *c) {
    u64 suma = 0;
    #pragma unroll
    for (int i = 0; i < 16; i++) {
        if (i >= c->n) break;
        u32 k = c->datos[i];
        u64 *v = bpf_map_lookup_elem(&cuentas, &k);
        if (v) { *v += 1; } else { u64 uno = 1; bpf_map_update_elem(&cuentas, &k, &uno, 0); }
        suma += k * (i + 1);
    }
    u32 cero = 0;
    u64 *t = bpf_map_lookup_elem(&total, &cero);
    if (t) *t += suma;
    char fmt[] = "suma %llu de %u\n";
    bpf_trace_printk(fmt, sizeof(fmt), suma, c->n);
    return suma % 1000;
}
char _licencia[] SEC("license") = "GPL";
