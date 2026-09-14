#Requires -Version 5.1
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$ReplaceExisting
)

$ErrorActionPreference = "Stop"
function Invoke-Installer {
    param([string]$Script)
    $args = @("-ExecutionPolicy", "Bypass", "-File", $Script)
    if ($ReplaceExisting) { $args += "-ReplaceExisting" }
    & powershell @args
    if ($LASTEXITCODE -ne 0) { throw "Installer failed: $Script" }
}

Invoke-Installer (Join-Path $RepoRoot "scripts\install-cursor-global.ps1")

$projectsRoot = Join-Path $RepoRoot "projects"
$projects = Get-ChildItem $projectsRoot -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "scripts\install-cursor.ps1")
}

if ($projects.Count -eq 0) {
    Write-Host "No project-specific installers found."
    exit 0
}

Write-Host ""
Write-Host "发现以下项目专属技能："
for ($i = 0; $i -lt $projects.Count; $i++) {
    Write-Host "$($i + 1). $($projects[$i].Name)"
}
$choice = Read-Host "请输入要安装的项目编号（可用逗号分隔），或输入 N 跳过"

if ($choice -match '^[Nn]$') {
    Write-Host "Skipped all project-specific skills."
    exit 0
}

$indexes = $choice -split ',' | ForEach-Object {
    $number = 0
    if ([int]::TryParse($_.Trim(), [ref]$number)) { $number - 1 }
}
foreach ($index in $indexes | Select-Object -Unique) {
    if ($index -lt 0 -or $index -ge $projects.Count) {
        throw "Invalid project selection: $($index + 1)"
    }
    $projectRoot = $projects[$index].FullName
    Invoke-Installer (Join-Path $projectRoot "scripts\install-cursor.ps1")
    if (Test-Path (Join-Path $projectRoot "scripts\install-codex.ps1")) {
        Invoke-Installer (Join-Path $projectRoot "scripts\install-codex.ps1")
    }
    if (Test-Path (Join-Path $projectRoot "scripts\install-vscode.ps1")) {
        Invoke-Installer (Join-Path $projectRoot "scripts\install-vscode.ps1")
    }
}

Write-Host "All selected generic and project skills installed."
