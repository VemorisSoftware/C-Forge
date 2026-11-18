# ── C-Forge Dockerfile ─────────────────────────────────────────────────────────
# C-Forge 100 % C-Forge: la semilla incluida compila cforge (sin C++ ni libc).
#   docker build -t cforge .
#   docker run --rm -v $(pwd):/work cforge run /work/mi_script.cfv

# ── Etapa 1: la semilla compila cforge ────────────────────────────────────────
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends make \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY Makefile ./
COPY bootstrap/ ./bootstrap/
COPY runtime/   ./runtime/
COPY stdlib/    ./stdlib/
RUN make build

# ── Etapa 2: imagen de ejecución ──────────────────────────────────────────────
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
# git: cforge add (paquetes de GitHub); ca-certificates para HTTPS.
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /src/cforge /usr/local/bin/cforge
COPY stdlib/ /opt/cforge/stdlib/
ENV CFORGE_STDLIB=/opt/cforge/stdlib
WORKDIR /work
ENTRYPOINT ["cforge"]
CMD ["--help"]
