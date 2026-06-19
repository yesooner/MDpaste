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
$markerPath = Join-Path $configDir ".portable-home"
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
Set-JsonProperty $config "notify" $false
Set-JsonProperty $config "startup_notify" $false

# Set default hotkey if not present
if (-not $config.PSObject.Properties["hotkey"]) {
  Set-JsonProperty $config "hotkey" "<ctrl>+<alt>+b"
}

# Set latex defaults only for old configs that do not have these keys yet.
# Do not overwrite user choices here; disabling these can be necessary when
# Markdown preprocessing is too slow for large AI/chat clipboard payloads.
if (-not $config.PSObject.Properties["enable_latex_replacements"]) {
  Set-JsonProperty $config "enable_latex_replacements" $true
}
if (-not $config.PSObject.Properties["fix_single_dollar_block"]) {
  Set-JsonProperty $config "fix_single_dollar_block" $true
}
if (-not $config.PSObject.Properties["convert_standard_latex_delimiters"]) {
  Set-JsonProperty $config "convert_standard_latex_delimiters" $true
}

$json = $config | ConvertTo-Json -Depth 20
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, $json, $utf8NoBom)
[System.IO.File]::WriteAllText($markerPath, $homePath, $utf8NoBom)

Write-Host "[OK] PasteMD portable config updated for: $homePath"
