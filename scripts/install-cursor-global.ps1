#Requires -Version 5.1
<#
.SYNOPSIS
  Link cqone engineering skills and code-standards rule into ~/.cursor (global).

.DESCRIPTION
  - skills/engineering/code-standards  -> %USERPROFILE%\.cursor\skills\code-standards
  - skills/engineering/laya-module-scaffold -> %USERPROFILE%\.cursor\skills\laya-module-scaffold
  - .cursor/rules/code-standards.mdc -> %USERPROFILE%\.cursor\rules\code-standards.mdc

  Re-run after git pull to refresh junction targets (same paths, updated content).
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$cursorSkills = Join-Path $env:USERPROFILE ".cursor\skills"
$cursorRules = Join-Path $env:USERPROFILE ".cursor\rules"

$links = @(
    @{
        Link   = Join-Path $cursorSkills "code-standards"
        Target = Join-Path $RepoRoot "skills\engineering\code-standards"
    },
    @{
        Link   = Join-Path $cursorSkills "laya-module-scaffold"
        Target = Join-Path $RepoRoot "skills\engineering\laya-module-scaffold"
    },
    @{
        Link   = Join-Path $cursorRules "code-standards.mdc"
        Target = Join-Path $RepoRoot ".cursor\rules\code-standards.mdc"
    }
)

function Set-RepoLink {
    param([string]$Link, [string]$Target)
    if (-not (Test-Path $Target)) {
        throw "Target not found: $Target"
    }
    if (Test-Path $Link) {
        Remove-Item -LiteralPath $Link -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    }
    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path $Target -PathType Container) {
        New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    } else {
        try {
            New-Item -ItemType HardLink -Path $Link -Target $Target | Out-Null
        } catch {
            Copy-Item -LiteralPath $Target -Destination $Link -Force
            Write-Warning "HardLink denied; copied file instead. Re-run install after git pull to refresh."
        }
    }
    Write-Host "linked $Link -> $Target"
}

foreach ($item in $links) {
    Set-RepoLink -Link $item.Link -Target $item.Target
}

Write-Host ""
Write-Host "Global Cursor config installed from: $RepoRoot"
Write-Host "Restart Cursor or open a new chat if rules/skills do not refresh."
