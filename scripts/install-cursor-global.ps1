#Requires -Version 5.1
<#
.SYNOPSIS
  Link generic Cursor skills and rules into ~/.cursor (global).

.DESCRIPTION
  - skills/karpathy-guidelines -> %USERPROFILE%\.cursor\skills\karpathy-guidelines
  - skills/skill-variant-sync -> %USERPROFILE%\.cursor\skills\skill-variant-sync
  - .cursor/rules/karpathy-guidelines.mdc -> %USERPROFILE%\.cursor\rules\karpathy-guidelines.mdc
  - .cursor/rules/grill-me.mdc -> %USERPROFILE%\.cursor\rules\grill-me.mdc

  Project-specific skills are isolated under projects/<project>/ and require
  their explicit installer. Existing non-link targets are preserved unless
  -ReplaceExisting is supplied.
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"

$cursorSkills = Join-Path $env:USERPROFILE ".cursor\skills"
$cursorRules = Join-Path $env:USERPROFILE ".cursor\rules"

$links = @(
    @{
        Link   = Join-Path $cursorSkills "karpathy-guidelines"
        Target = Join-Path $RepoRoot "skills\karpathy-guidelines"
    },
    @{
        Link   = Join-Path $cursorRules "karpathy-guidelines.mdc"
        Target = Join-Path $RepoRoot ".cursor\rules\karpathy-guidelines.mdc"
    },
    @{
        Link   = Join-Path $cursorRules "grill-me.mdc"
        Target = Join-Path $RepoRoot ".cursor\rules\grill-me.mdc"
    },
    @{
        Link   = Join-Path $cursorSkills "skill-variant-sync"
        Target = Join-Path $RepoRoot "skills\skill-variant-sync"
    }
)

function Set-RepoLink {
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
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
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

foreach ($item in $links) {
    Set-RepoLink -Link $item.Link -Target $item.Target
}

Write-Host ""
Write-Host "Generic Cursor config installed from: $RepoRoot"
Write-Host "Project-specific skills require an explicit projects/<project>/ installer."
