#Requires -Version 5.1
<#
.SYNOPSIS
  Link generic (project-independent) skills into the user-level skill
  directories of Codex, WorkBuddy, CodeBuddy and VS Code / Copilot.

.DESCRIPTION
  Counterpart of install-cursor-global.ps1 for the non-Cursor harnesses.
  It installs the generic set shipped by this repository's skills\ directory
  (karpathy-guidelines and the self-contained grill-me skill), so every tool
  sees identical generic guidance. Project-specific skills stay isolated under
  projects/<project>/ and are NOT touched by this script.

  Only skills that exist under <repo>\skills\<name> are eligible. Cursor is not
  handled here: it receives grill-me as a rule (.cursor\rules\grill-me.mdc)
  instead of a skill, see install-cursor-global.ps1.

  Targets:
    codex     -> %USERPROFILE%\.codex\skills\<skill>
    workbuddy -> %USERPROFILE%\.workbuddy\skills\<skill>
    codebuddy -> %USERPROFILE%\.codebuddy\skills\<skill>
    vscode    -> %USERPROFILE%\.copilot\skills\<skill>

  Existing non-link targets are preserved unless -ReplaceExisting is supplied.
  Note: VS Code rule files (prompts\*.instructions.md) are user-level config
  with no generic source in this repository, so they are left untouched.
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [ValidateSet("codex", "workbuddy", "codebuddy", "vscode")]
    [string[]]$Platforms = @("codex", "workbuddy", "codebuddy", "vscode"),
    [string[]]$Skills = @("karpathy-guidelines", "grill-me"),
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"

$skillRoot = Join-Path $RepoRoot "skills"

$platformRoots = @{
    codex     = Join-Path $env:USERPROFILE ".codex\skills"
    workbuddy = Join-Path $env:USERPROFILE ".workbuddy\skills"
    codebuddy = Join-Path $env:USERPROFILE ".codebuddy\skills"
    vscode    = Join-Path $env:USERPROFILE ".copilot\skills"
}

foreach ($skill in $Skills) {
    if (-not (Test-Path -LiteralPath (Join-Path $skillRoot $skill) -PathType Container)) {
        throw "Generic skill not found in this repository: $skill"
    }
}

function Set-RepoLink {
    param([string]$Link, [string]$Target)

    if (-not (Test-Path -LiteralPath $Target)) {
        throw "Target not found: $Target"
    }
    $item = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $isLink = $item.LinkType -in @("Junction", "SymbolicLink")
        # Already linked to the right place: nothing to do. Skipping the delete
        # keeps re-runs idempotent and avoids touching the link at all.
        if ($isLink -and ($item.Target | Where-Object { $_ -eq $Target })) {
            Write-Host "already linked $Link -> $Target"
            return
        }
        if (-not $isLink -and -not $ReplaceExisting) {
            throw "Refusing to replace a non-link path: $Link. Re-run with -ReplaceExisting after reviewing it."
        }
        Remove-Item -LiteralPath $Link -Recurse -Force
    }
    $parent = Split-Path -Path $Link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Host "linked $Link -> $Target"
}

foreach ($platform in $Platforms) {
    $destRoot = $platformRoots[$platform]
    foreach ($skill in $Skills) {
        Set-RepoLink -Link (Join-Path $destRoot $skill) -Target (Join-Path $skillRoot $skill)
    }
}

Write-Host ""
Write-Host "Generic skills installed for: $($Platforms -join ', ')"
Write-Host "Skills: $($Skills -join ', ')"
Write-Host "Generic source: $skillRoot"
Write-Host "Project-specific skills require an explicit projects/<project>/ installer."
