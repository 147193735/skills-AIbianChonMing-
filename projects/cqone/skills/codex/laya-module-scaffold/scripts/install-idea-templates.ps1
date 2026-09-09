#Requires -Version 5.1
<#
.SYNOPSIS
  安装 CQone IDEA File Templates 到 IntelliJ IDEA 2025.1 用户目录。

.USAGE
  powershell -ExecutionPolicy Bypass -File scripts/install-idea-templates.ps1
  powershell -ExecutionPolicy Bypass -File scripts/install-idea-templates.ps1 -IdeaVersion "2025.1"
#>
param(
    [string]$IdeaVersion = "2025.1"
)

$ErrorActionPreference = "Stop"
$skillRoot = Split-Path -Parent $PSScriptRoot
$srcDir = Join-Path $skillRoot "idea-templates"
$destDir = Join-Path $env:APPDATA "JetBrains\IntelliJIdea$IdeaVersion\fileTemplates"

if (-not (Test-Path $srcDir)) {
    Write-Error "找不到模板目录: $srcDir"
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $destDir "includes") | Out-Null

Copy-Item -Path (Join-Path $srcDir "CQ Module*.ts") -Destination $destDir -Force
Copy-Item -Path (Join-Path $srcDir "includes\CQ File Header.ts") -Destination (Join-Path $destDir "includes\") -Force

Write-Host "已安装 IDEA 模板到: $destDir"
Write-Host "请在 IDEA: Settings -> Editor -> File and Code Templates 中勾选 Reformat according to style (tuoqi)"
