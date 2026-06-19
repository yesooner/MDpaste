param(
  [string]$Version = "0.1.8"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $root "dist"
$staging = Join-Path $dist "MDPASTE-portable-v$Version"
$zipPath = Join-Path $dist "MDPASTE-portable-v$Version.zip"

if (Test-Path -LiteralPath $staging) {
  Remove-Item -LiteralPath $staging -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $staging, $dist | Out-Null

function Copy-ReleaseItem {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Target
  )

  $sourceItem = Get-Item -LiteralPath $Source
  if (-not $sourceItem.PSIsContainer) {
    Copy-Item -LiteralPath $Source -Destination $Target
    return
  }

  New-Item -ItemType Directory -Force -Path $Target | Out-Null
  Get-ChildItem -LiteralPath $Source -Recurse -Force | Where-Object {
    $_.Name -ne "__pycache__" -and $_.Name -notlike "*.pyc"
  } | ForEach-Object {
    $relative = $_.FullName.Substring($sourceItem.FullName.Length).TrimStart("\", "/")
    $destination = Join-Path $Target $relative
    if ($_.PSIsContainer) {
      New-Item -ItemType Directory -Force -Path $destination | Out-Null
    } else {
      $parent = Split-Path -Parent $destination
      New-Item -ItemType Directory -Force -Path $parent | Out-Null
      Copy-Item -LiteralPath $_.FullName -Destination $destination
    }
  }
}

$include = @(
  "MdPaste.exe",
  "MdPaste-portable-launcher.exe",
  "_internal",
  "assets",
  "pastemd",
  "MDPASTE.cmd",
  "MdPaste-portable.cmd",
  "portable-config.ps1",
  "build-release.ps1",
  "build-installer.ps1",
  "installer.iss",
  "switch-startup.cmd",
  "README.md",
  "i18n",
  "RELEASE_NOTES.md",
  "MODIFICATIONS.md",
  "UPSTREAM_COMPARISON.md",
  "SOURCE.md",
  "tools",
  "LICENSE",
  "NOTICE.md"
)

foreach ($item in $include) {
  $source = Join-Path $root $item
  if (-not (Test-Path -LiteralPath $source)) {
    throw "Missing required release item: $item"
  }

  $target = Join-Path $staging $item
  Copy-ReleaseItem -Source $source -Target $target
}

New-Item -ItemType Directory -Force -Path (Join-Path $staging "cache") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging "portable-data\Roaming") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging "portable-data\Local") | Out-Null

if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -LiteralPath $staging -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "[OK] Release package created: $zipPath"
