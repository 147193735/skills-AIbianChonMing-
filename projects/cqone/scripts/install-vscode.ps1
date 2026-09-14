#Requires -Version 5.1
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"
$promptRoot = Join-Path $env:APPDATA "Code\User\prompts"
$skillRoot = Join-Path $env:USERPROFILE ".copilot\skills"
$sourceRoot = Join-Path $ProjectRoot "skills\vscode"
New-Item -ItemType Directory -Path $promptRoot -Force | Out-Null
New-Item -ItemType Directory -Path $skillRoot -Force | Out-Null

Get-ChildItem $sourceRoot -Directory | ForEach-Object {
    $target = Join-Path $skillRoot $_.Name
    $item = Get-Item $target -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $isLink = $item.LinkType -in @("Junction", "SymbolicLink")
        if (-not $isLink -and -not $ReplaceExisting) {
            throw "Refusing to replace existing skill directory: $target"
        }
        Remove-Item $target -Recurse -Force
    }
    New-Item -ItemType Junction -Path $target -Target $_.FullName | Out-Null
    Write-Host "linked $target -> $($_.FullName)"
}

Get-ChildItem $sourceRoot -Recurse -File -Filter "*.instructions.md" | ForEach-Object {
    $target = Join-Path $promptRoot $_.Name
    if ((Test-Path $target) -and -not $ReplaceExisting) {
        throw "Refusing to replace existing prompt: $target. Re-run with -ReplaceExisting after reviewing it."
    }
    Copy-Item $_.FullName $target -Force
    Write-Host "installed $target"
}
Write-Host "cqone VS Code prompts installed from: $sourceRoot"
