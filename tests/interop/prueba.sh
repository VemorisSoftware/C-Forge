#!/bin/sh
# tests/interop/prueba.sh COMPILADOR — Java (JNI), C# (.NET, hostfxr), C++
# (clang++) y Rust (cargo) dentro de un programa C-Forge. Cada parte se salta
# si falta su SDK.
set -e
C=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
RAIZ=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d)
cp -r "$RAIZ"/tests/interop/* "$T/"
cd "$T"
export CFORGE_STDLIB="$RAIZ/stdlib"
unset JAVA_TOOL_OPTIONS _JAVA_OPTIONS
if command -v javac >/dev/null 2>&1; then
    javac Saludo.java
    "$C" java.cfv > java.txt 2>/dev/null
    cat > java.esperado <<'F'
Hola Javier desde Java
42
2432902008176640000
2.5
9
F
    head -5 java.txt | diff -u java.esperado -
    sed -n 7,8p java.txt | tr '\n' ' ' | grep -q '^2 \[uno, dos\] $'
    grep -q 'capturado: java: Saludo.falla: java.lang.IllegalStateException: roto' java.txt
    grep -q 'capturado: java: FindClass NoExiste: java.lang.NoClassDefFoundError: NoExiste' java.txt
    echo "  ✓ Java (JNI): estáticos, objetos, long, String y excepciones"
else
    echo "  - Java: sin JDK, se salta"
fi
if command -v dotnet >/dev/null 2>&1; then
    BASE=$(dirname "$(readlink -f "$(command -v dotnet)")")
    SDK=$(ls -d "$BASE"/sdk/*/ | sort -V | tail -1)
    RT=$(ls -d "$BASE"/shared/Microsoft.NETCore.App/*/ | sort -V | tail -1)
    mkdir -p bin
    dotnet "$SDK/Roslyn/bincore/csc.dll" -nologo -target:library -nostdlib -out:bin/Calc.dll \
        -r:"$RT/System.Runtime.dll" -r:"$RT/System.Runtime.InteropServices.dll" -r:"$RT/System.Private.CoreLib.dll" Calc.cs >/dev/null
    DOTNET_ROOT="$BASE" "$C" dotnet.cfv > dotnet.txt
    sed -n 1,2p dotnet.txt | tr '\n' ' ' | grep -q '^42 2432902008176640000 $'
    grep -q '^Hola Javier desde C# ' dotnet.txt
    grep -q 'capturado: dotnet: no se encontró Calc, Calc.NoExiste' dotnet.txt
    echo "  ✓ C# (.NET): [UnmanagedCallersOnly], long y textos UTF-8"
else
    echo "  - C#: sin .NET, se salta"
fi
export CFORGE_INTEROP="$T/interop"
if command -v clang++ >/dev/null 2>&1; then
    "$C" bindgen cpp/geo.hpp --fuentes cpp/geo.cpp | grep -q '31 funciones; 1 omitidas → importar "cpp:geo"'
    "$C" cpp.cfv > cpp.txt
    cat > cpp.esperado <<'F'
5
(4, 5)
8
[3, 12, [0, 3, 3], triángulo]
4
[3.14159, 5, 5.5, 2432902008176640000, 2.5, verdadero]
[¡Hola, Javier!, 2.16667, [2, 3, 4, 5], [a, b, , c], x-y-z]
32.8084
error: geo: raíz de un negativo
error: geo: vértice fuera de rango
error: geo: lista vacía
fin
F
    diff -u cpp.esperado cpp.txt
    "$C" build cpp.cfv --release -o cpp_rel >/dev/null
    ./cpp_rel | diff -u cpp.esperado -
    echo "  ✓ C++ (clang++): clases, sobrecargas, std::string, std::vector, enums y excepciones"
else
    echo "  - C++: sin clang++, se salta"
fi
if command -v cargo >/dev/null 2>&1; then
    "$C" bindgen rust:rust/inventario | grep -q '26 funciones; 1 omitidas → importar "rust:inventario"'
    "$C" rust.cfv > rust.txt
    cat > rust.esperado <<'F'
[45, café ($4.50 × 10), café, 10]
7
error: inventario: solo quedan 7
[4.05, 4.5]
[2, [café, té], [4.5, 3], 91.5]
20
0
[46, 2.333, nulo, [ÑU, AB], ñ, verdadero, aloh]
error: inventario: pánico: división por cero
4
fin
F
    diff -u rust.esperado rust.txt
    "$C" build rust.cfv --release -o rust_rel >/dev/null
    ./rust_rel | diff -u rust.esperado -
    echo "  ✓ Rust (cargo): structs, métodos, campos, Result, Option, Vec, String y pánicos"
else
    echo "  - Rust: sin cargo, se salta"
fi
cd /; rm -rf "$T"
