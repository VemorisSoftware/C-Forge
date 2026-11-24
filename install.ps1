# ============================================================================
# Instalador oficial de C-Forge para Windows — https://c-forge.org
#
#   irm https://c-forge.org/install.ps1 | iex
#
# Variables opcionales:
#   $env:CFORGE_VERSION = "5.0.0"   instala una versión concreta
# ============================================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo = 'VemorisSoftware/cforge'
$GitHub = "https://github.com/$Repo"

function Info($m) { Write-Host "[C-Forge] $m" }
function Fail($m) { Write-Host "[error] $m" -ForegroundColor Red; exit 1 }

if (-not [Environment]::Is64BitOperatingSystem) { Fail 'C-Forge requiere Windows de 64 bits.' }

# ── Versión ────────────────────────────────────────────────────────────────
$Version = $env:CFORGE_VERSION
if (-not $Version) {
  try {
    $req = [System.Net.WebRequest]::Create("$GitHub/releases/latest")
    $req.AllowAutoRedirect = $false
    $resp = $req.GetResponse()
    $Version = ($resp.Headers['Location'] -split '/tag/v?')[-1]
    $resp.Close()
  } catch { }
  if (-not $Version) { Fail 'no se pudo detectar la última versión; define $env:CFORGE_VERSION' }
}
$Version = $Version.TrimStart('v')
if ($Version -notmatch '^[0-9]+(\.[0-9]+)*$') { Fail "versión inválida: $Version (ejemplo: 5.0.0)" }

$Name = "cforge-$Version-windows-x64"
$Base = "$GitHub/releases/download/v$Version"
$Dest = Join-Path $env:LOCALAPPDATA 'Programs\cforge'
$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("cforge-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
  Info "instalando C-Forge v$Version"
  $Zip = Join-Path $Tmp "$Name.zip"
  Invoke-WebRequest "$Base/$Name.zip" -OutFile $Zip -UseBasicParsing

  # Verificación SHA-256 obligatoria: sin SHA256SUMS no se instala nada.
  try {
    $sums = (Invoke-WebRequest "$Base/SHA256SUMS" -UseBasicParsing).Content
  } catch { Fail 'no se pudo descargar SHA256SUMS para verificar la descarga' }
  if ($sums -is [byte[]]) { $sums = [Text.Encoding]::UTF8.GetString($sums) }
  $line = ($sums -split "`n") | Where-Object { $_ -match " $([regex]::Escape("$Name.zip"))\s*$" } | Select-Object -First 1
  if (-not $line) { Fail "SHA256SUMS no incluye $Name.zip" }
  $expected = ($line -split '\s+')[0].ToLower()
  $actual = (Get-FileHash $Zip -Algorithm SHA256).Hash.ToLower()
  if ($expected -ne $actual) { Fail 'la suma SHA-256 no coincide; descarga corrupta' }
  Info 'SHA-256 verificado'

  Expand-Archive $Zip -DestinationPath $Tmp -Force
  $Src = Join-Path $Tmp $Name
  if (-not (Test-Path (Join-Path $Src 'cforge.exe'))) { Fail 'el paquete no contiene cforge.exe' }

  if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
  New-Item -ItemType Directory -Path $Dest | Out-Null
  Copy-Item (Join-Path $Src '*') $Dest -Recurse -Force
  Copy-Item (Join-Path $Dest 'cforge.exe') (Join-Path $Dest 'c-forge.exe') -Force
} finally {
  Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}

# ── PATH del usuario ───────────────────────────────────────────────────────
$UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($UserPath -split ';') -contains $Dest)) {
  [Environment]::SetEnvironmentVariable('Path', (($UserPath, $Dest) -join ';').Trim(';'), 'User')
  Info "agregado $Dest al PATH (abre una terminal nueva)"
}
$env:Path = "$Dest;$env:Path"

$installed = & (Join-Path $Dest 'cforge.exe') --version
Write-Host ""
Write-Host "[C-Forge] $installed instalado en $Dest" -ForegroundColor Green
Write-Host ""
Write-Host "  Prueba:"
Write-Host "    [IO.File]::WriteAllText(""`$PWD\hola.cfv"", 'mostrar(""Hola, mundo"")')"
Write-Host "    cforge hola.cfv"
Write-Host ""
