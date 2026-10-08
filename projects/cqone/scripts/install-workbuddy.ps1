#Requires -Version 5.1
<#
.SYNOPSIS
  Explicitly install cqone-specific WorkBuddy skills.

.DESCRIPTION
  This script is intentionally project-scoped. The root global installer only
  installs generic skills. Existing non-link paths are preserved unless
  -ReplaceExisting is supplied.

  WorkBuddy reads user-level skills from %USERPROFILE%\.workbuddy\skills.
  The workbuddy variant is the Codex archive plus WorkBuddy path adaptations,
  so WorkBuddy and CodeBuddy stay on the same skill content.
#>
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"
$workbuddySkills = Join-Path $env:USERPROFILE ".workbuddy\skills"
$skillNames = @(
    "acts-module",
    "code-check",
    "code-standards",
    "fgui-ui-elements",
    "fgui-ui-naming",
    "gain-reward-prize-type",
    "laya-fgui-engine-source",
    "laya-module-scaffold",
    "my-features"
)

function Set-ProjectLink {
    param([string]$Link, [string]$Target)

    if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
        throw "Target not found: $Target"
    }
    $item = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $isLink = $item.LinkType -in @("Junction", "SymbolicLink")
        if (-not $isLink -and -not $ReplaceExisting) {
            throw "Refusing to replace a non-link path: $Link. Re-run with -ReplaceExisting after reviewing it."
        }
        Remove-Item -LiteralPath $Link -Recurse -Force
    }
    $parent = Split-Path -Path $Link -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Host "linked $Link -> $Target"
}

foreach ($name in $skillNames) {
    Set-ProjectLink (Join-Path $workbuddySkills $name) (Join-Path $ProjectRoot "skills\workbuddy\$name")
}

Write-Host "cqone WorkBuddy skills installed from: $ProjectRoot"
