#Requires -Version 5.1
<#
.SYNOPSIS
  Link the generic VS Code / Copilot prompt files shipped by this repository
  into the user-level prompts directory.

.DESCRIPTION
  VS Code reads instructions from %APPDATA%\Code\User\prompts\*.instructions.md,
  a flat file directory that cannot mirror the repository layout. Generic skills
  keep their VS Code variant next to the skill itself:

    skills\<skill>\<skill>.instructions.md

  This installer links those files into the prompts directory (HardLink when
  possible, Copy-Item as fallback), so editing the repository stays in sync.
  Adding a new generic skill only requires dropping the correctly named
  `<skill>.instructions.md` next to its SKILL.md - no whitelist to update.

  Project-specific prompts are NOT handled here: each project ships its own
  projects\<project>\scripts\install-vscode.ps1.

  Prompt files that exist only in the user profile and have no repository source
  are never touched or deleted. Existing non-link files are preserved unless
  -ReplaceExisting is supplied.
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$PromptsDir = (Join-Path $env:APPDATA "Code\User\prompts"),
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PromptsDir)) {
    New-Item -ItemType Directory -Path $PromptsDir -Force | Out-Null
}

$sources = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills\*\*.instructions.md") -File -ErrorAction SilentlyContinue)

if ($sources.Count -eq 0) {
    Write-Host "No generic prompt files found under: $(Join-Path $RepoRoot 'skills')"
    exit 0
}

function Set-PromptLink {
    param([string]$Source, [string]$Destination)

    $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $isLink = $item.LinkType -in @("HardLink", "SymbolicLink", "Junction")
        if (-not $isLink -and -not $ReplaceExisting) {
            throw "Refusing to replace a non-link file: $Dest. Re-run with -ReplaceExisting after reviewing it."
        }
        Remove-Item -LiteralPath $Destination -Force
    }

    try {
        New-Item -ItemType HardLink -Path $Destination -Target $Source | Out-Null
        Write-Host "linked $(Split-Path $Destination -Leaf) -> $Source"
    } catch {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Warning "HardLink denied for $(Split-Path $Destination -Leaf); copied instead. Re-run this installer after repository updates."
    }
}

foreach ($source in $sources | Sort-Object -Property Name) {
    Set-PromptLink -Source $source.FullName -Destination (Join-Path $PromptsDir $source.Name)
}

Write-Host ""
Write-Host "Generic VS Code prompts installed into: $PromptsDir"
Write-Host "Sources: $($sources.Count) from $(Join-Path $RepoRoot 'skills')"
Write-Host "Project prompts come from projects\<project>\scripts\install-vscode.ps1."
Write-Host "Prompt files with no repository source are left untouched."
