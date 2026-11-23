import "math"
/* Reglas de prueba de huella: comparadas con yara-python 4.5 */
rule PE_basico : ejecutable windows
{
    meta:
        autor = "Vemoris"
        version = 2
        activa = true
    strings:
        $mz = { 4D 5A }
        $pe = "PE\x00\x00"
    condition:
        $mz at 0 and uint16(0) == 0x5A4D and $pe in (0..256) and uint32(0x3C) < filesize
}

rule Texto_sospechoso
{
    strings:
        $a = "cmd.exe" nocase
        $b = "powershell" wide ascii nocase
        $c = /https?:\/\/[a-z0-9.\-]+\.(xyz|top)\b/i
        $d = "secreto" xor(1-5)
        $e = "token" fullword private
    condition:
        2 of ($a, $b, $c) or ($d and #e > 1)
}

rule Hex_saltos
{
    strings:
        $h1 = { E8 ?? ?? ?? ?? [0-3] 5? C3 }
        $h2 = { 6A 40 ( 68 00 30 00 00 | 68 00 10 00 00 ) 6A 00 }
    condition:
        any of them
}

rule Cuentas
{
    strings:
        $x = "AB"
        $y = "CD"
    condition:
        #x == 3 and #y in (0..10) >= 1 and @x[2] - @x[1] == 3 and !x[1] == 2 and for all i in (1..#x) : ( @x[i] < 20 )
}

rule Para_cada_cadena
{
    strings:
        $p1 = "uno"
        $p2 = "dos"
        $p3 = "tres"
    condition:
        for any of ($p*) : ( $ at 0 ) and 50% of them and not none of ($p1, $p2)
}

private rule Base_privada
{
    strings:
        $k = "clave"
    condition:
        $k
}

rule Usa_privada
{
    condition:
        Base_privada and filesize < 1KB and (uint8(0) ^ 0xFF) != 0 and int8(1) > 100 and uint32be(0) != 0 and (filesize \ 2) * 2 <= filesize and 7 % 3 == 1 and (1 << 4) == 16 and ~0 == -1
}

rule Regex_completa
{
    strings:
        $r1 = /[A-Z]{3}-\d{2,4}/
        $r2 = /a.*?b/s
        $r3 = /^inicio/
        $r4 = /(foo|ba[rz])+!/
    condition:
        $r1 or $r2 or $r3 or $r4
}

rule Reglas_de_reglas
{
    condition:
        any of (Cuentas, Hex_*)
}
