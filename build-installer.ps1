param(
  [string]$Version = "0.1.2",
  [string]$InnoSetupCompiler = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$issPath = Join-Path $root "installer.iss"

if (-not (Test-Path -LiteralPath $issPath)) {
  throw "Missing installer script: $issPath"
}

$required = @(
  "MdPaste.exe",
  "_internal\pandoc\pandoc.exe",
  "MDPASTE.cmd",
  "MdPaste-portable.cmd",
  "portable-config.ps1",
  "assets\icons\logo.ico"
)

foreach ($item in $required) {
  $path = Join-Path $root $item
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required installer input: $item"
  }
}

if (-not $InnoSetupCompiler) {
  $candidates = @(
    "F:\InnoSetup6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 5\ISCC.exe"
  )

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      $InnoSetupCompiler = $candidate
      break
    }
  }
}

if (-not $InnoSetupCompiler) {
  throw "Inno Setup compiler was not found. Install it with: winget install JRSoftware.InnoSetup"
}

if (-not (Test-Path -LiteralPath $InnoSetupCompiler)) {
  throw "Inno Setup compiler not found: $InnoSetupCompiler"
}

& $InnoSetupCompiler "/DAppVersion=$Version" $issPath
if ($LASTEXITCODE -ne 0) {
  throw "Inno Setup failed with exit code $LASTEXITCODE"
}

Write-Host "[OK] Installer created: $(Join-Path $root "dist\MDPASTE-Setup-v$Version.exe")"
