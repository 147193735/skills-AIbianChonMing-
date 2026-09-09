#Requires -Version 5.1
<#
.SYNOPSIS
  Explicitly install cqone-specific Cursor skills and rules.

.DESCRIPTION
  This script is intentionally project-scoped. The root global installer only
  installs generic skills. Existing non-link paths are preserved unless
  -ReplaceExisting is supplied.
#>
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"
$cursorSkills = Join-Path $env:USERPROFILE ".cursor\skills"
$cursorRules = Join-Path $env:USERPROFILE ".cursor\rules"
$skillNames = @(
    "acts-module",
    "code-check",
    "code-standards",
    "fgui-ui-elements",
    "fgui-ui-naming",
    "laya-fgui-engine-source",
    "laya-module-scaffold",
    "my-features"
)
$ruleNames = @("code-standards.mdc", "laya-fgui-engine-source.mdc")

function Set-ProjectLink {
    param([string]$Link, [string]$Target)

    if (-not (Test-Path -LiteralPath $Target)) {
        throw "Target not found: $Target"
    }
    $item = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $isLink = $item.LinkType -in @("Junction", "SymbolicLink", "HardLink")
        if (-not $isLink -and -not $ReplaceExisting) {
            throw "Refusing to replace a non-link path: $Link. Re-run with -ReplaceExisting after reviewing it."
        }
        Remove-Item -LiteralPath $Link -Recurse -Force
    }
    $parent = Split-Path -Path $Link -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    if (Test-Path -LiteralPath $Target -PathType Container) {
        New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    } else {
        try {
            New-Item -ItemType HardLink -Path $Link -Target $Target | Out-Null
        } catch {
            Copy-Item -LiteralPath $Target -Destination $Link -Force
            Write-Warning "HardLink denied; copied file instead. Re-run the installer after updating this repository."
        }
    }
    Write-Host "linked $Link -> $Target"
}

foreach ($name in $skillNames) {
    Set-ProjectLink (Join-Path $cursorSkills $name) (Join-Path $ProjectRoot "skills\cursor\$name")
}
foreach ($name in $ruleNames) {
    Set-ProjectLink (Join-Path $cursorRules $name) (Join-Path $ProjectRoot "cursor\rules\$name")
}

Write-Host "cqone Cursor skills installed from: $ProjectRoot"
