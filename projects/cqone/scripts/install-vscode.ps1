#Requires -Version 5.1
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"
$promptRoot = Join-Path $env:APPDATA "Code\User\prompts"
$sourceRoot = Join-Path $ProjectRoot "skills\vscode"
New-Item -ItemType Directory -Path $promptRoot -Force | Out-Null

Get-ChildItem $sourceRoot -Recurse -File -Filter "*.instructions.md" | ForEach-Object {
    $target = Join-Path $promptRoot $_.Name
    if ((Test-Path $target) -and -not $ReplaceExisting) {
        throw "Refusing to replace existing prompt: $target. Re-run with -ReplaceExisting after reviewing it."
    }
    Copy-Item $_.FullName $target -Force
    Write-Host "installed $target"
}
Write-Host "cqone VS Code prompts installed from: $sourceRoot"
