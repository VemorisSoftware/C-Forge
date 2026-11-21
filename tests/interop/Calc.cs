using System;
using System.Runtime.InteropServices;
public static class Calc {
    [UnmanagedCallersOnly] public static int Sumar(int a, int b) => a + b;
    [UnmanagedCallersOnly] public static long Factorial(int n) { long r = 1; for (int i = 2; i <= n; i++) r *= i; return r; }
    [UnmanagedCallersOnly] public static IntPtr Saludo(IntPtr nombre) =>
        Marshal.StringToCoTaskMemUTF8("Hola " + Marshal.PtrToStringUTF8(nombre) + " desde C# " + Environment.Version);
}
