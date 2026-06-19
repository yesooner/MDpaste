param(
  [string]$RootDir = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$root = [System.IO.Path]::GetFullPath($RootDir)
$source = Join-Path $root "tools\MdPastePortableLauncher.cs"
$output = Join-Path $root "MdPaste-portable-launcher.exe"
$csc = Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"

if (-not (Test-Path -LiteralPath $source)) {
  throw "Missing launcher source: $source"
}

if (-not (Test-Path -LiteralPath $csc)) {
  throw "Missing .NET Framework C# compiler: $csc"
}

& $csc `
  /nologo `
  /target:winexe `
  /out:$output `
  /reference:System.Web.Extensions.dll `
  /reference:System.Windows.Forms.dll `
  $source

if ($LASTEXITCODE -ne 0) {
  throw "Portable launcher build failed with exit code $LASTEXITCODE"
}

Write-Host "[OK] Built $output"
