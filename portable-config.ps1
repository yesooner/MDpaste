param(
  [Parameter(Mandatory = $true)]
  [string]$HomeDir
)

$ErrorActionPreference = "Stop"

$homePath = [System.IO.Path]::GetFullPath($HomeDir)
$portableRoaming = Join-Path $homePath "portable-data\Roaming"
$portableLocal = Join-Path $homePath "portable-data\Local"
$configDir = Join-Path $portableRoaming "PasteMD"
$cacheDir = Join-Path $homePath "cache"
$pandocPath = Join-Path $homePath "_internal\pandoc\pandoc.exe"

if (-not (Test-Path -LiteralPath $pandocPath)) {
  throw "Bundled Pandoc was not found: $pandocPath"
}

New-Item -ItemType Directory -Force -Path $configDir, $portableLocal, $cacheDir | Out-Null

function Set-JsonProperty {
  param(
    [Parameter(Mandatory = $true)]$Object,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)]$Value
  )

  $Object | Add-Member -Force -MemberType NoteProperty -Name $Name -Value $Value
}

$configPath = Join-Path $configDir "config.json"
if (Test-Path -LiteralPath $configPath) {
  $config = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
} else {
  $config = [pscustomobject]@{}
}

# Always rewrite paths to match current home directory.
# PasteMD stores absolute paths in config.json, so the portable launcher
# refreshes them on every start after the folder is moved.
$pandocAbsPath = Join-Path $homePath "_internal\pandoc\pandoc.exe"
$cacheAbsPath = Join-Path $homePath "cache"

Set-JsonProperty $config "pandoc_path" $pandocAbsPath
Set-JsonProperty $config "save_dir" $cacheAbsPath
Set-JsonProperty $config "auto_start" $false

# Set default hotkey if not present
if (-not $config.PSObject.Properties["hotkey"]) {
  Set-JsonProperty $config "hotkey" "<ctrl>+<alt>+b"
}

# Always ensure latex settings are enabled
Set-JsonProperty $config "enable_latex_replacements" $true
Set-JsonProperty $config "fix_single_dollar_block" $true
Set-JsonProperty $config "convert_standard_latex_delimiters" $true

$json = $config | ConvertTo-Json -Depth 20
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, $json, $utf8NoBom)

Write-Host "[OK] PasteMD portable config updated for: $homePath"
