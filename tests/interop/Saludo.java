public class Saludo {
    public static String hola(String n) { return "Hola " + n + " desde Java"; }
    public static int suma(int a, int b) { return a + b; }
    public static long factorial(int n) { long r = 1; for (int i = 2; i <= n; i++) r *= i; return r; }
    public static double mitad(double x) { return x / 2; }
    public static String mitadTexto(double x) { return String.valueOf(x / 2); }
    public static void falla() { throw new IllegalStateException("roto"); }
}
