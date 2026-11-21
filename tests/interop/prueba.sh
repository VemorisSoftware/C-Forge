#!/bin/sh
# tests/interop/prueba.sh COMPILADOR — Java (JNI) y C# (.NET, hostfxr) dentro
# de un programa C-Forge. Cada parte se salta si falta su SDK.
set -e
C=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
RAIZ=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d)
cp "$RAIZ"/tests/interop/* "$T/"
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
cd /; rm -rf "$T"
