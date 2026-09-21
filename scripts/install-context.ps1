# Land Cat Paw context in a Hermes home.
#
# SOUL.md is identity. On the Compose image, plow-init writes it every boot
# from the base persona plus /opt/hermes/plow-seed/persona.md (copied from
# PERSONA.md). This script does not touch that file in the container.
# An existing Hermes (-Home) has no plow-init, so a missing or stock SOUL.md
# is written from PERSONA.md. A soul someone already edited is left alone.
#
# AGENTS.md is never replaced. The Cat Paw section is appended, or refreshed
# if it is already there. When Latch has written HERMES.md, Hermes loads that
# file instead of AGENTS.md; the standing voice still lives in SOUL.md.
param(
    [Alias("Home")]
    [string]$HomeDir
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Persona = Join-Path $Root "PERSONA.md"
$Section = Join-Path $Root "context\AGENTS.section.md"
$ComposeFile = Join-Path $Root "compose.yml"
$Service = "hermes-cat-paw"
$Begin = "<!-- cat-paw:agents -->"
$End = "<!-- /cat-paw:agents -->"
$Utf8 = New-Object System.Text.UTF8Encoding $false

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path)
}

function Write-Utf8([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8)
}

function Get-MarkedSection {
    $body = Read-Utf8 $Section
    if (-not $body.EndsWith("`n")) { $body += "`n" }
    return "$Begin`n$body$End`n"
}

function Set-AgentsSection([string]$Path) {
    $block = Get-MarkedSection
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Utf8 $Path $block
        return
    }
    $text = Read-Utf8 $Path
    $start = $text.IndexOf($Begin)
    if ($start -lt 0) {
        if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text += "`n" }
        if ($text.Length -gt 0) { $text += "`n" }
        $text += $block
    } else {
        $stop = $text.IndexOf($End, $start)
        if ($stop -lt 0) {
            $text = $text.Substring(0, $start) + $block
        } else {
            $after = $stop + $End.Length
            if ($after -lt $text.Length -and ($text[$after] -eq "`n" -or $text[$after] -eq "`r")) { $after++ }
            if ($after -lt $text.Length -and $text[$after] -eq "`n") { $after++ }
            $text = $text.Substring(0, $start) + $block + $text.Substring($after)
        }
    }
    Write-Utf8 $Path $text
}

function Test-StockSoul([string]$Text) {
    $trimmed = ($Text -replace "`r", "").Trim()
    if (-not $trimmed) { return $true }
    return (
        $trimmed.StartsWith("You are Hermes Agent, built by Nous Research.") -or
        $trimmed.StartsWith("You are Hermes Agent, an intelligent AI assistant created by Nous Research.") -or
        $trimmed.StartsWith("# Hermes Agent Persona")
    )
}

function Set-HomeSoul([string]$Path) {
    $persona = Read-Utf8 $Persona
    if (-not $persona.EndsWith("`n")) { $persona += "`n" }
    if (Test-Path -LiteralPath $Path) {
        $text = Read-Utf8 $Path
        $ours = $text.Contains("# Cat Paw") -and $text.Contains("chaotic builder cat")
        if (-not (Test-StockSoul $text) -and -not $ours) {
            Write-Host "install-context.ps1: leaving existing SOUL.md"
            return
        }
        if ($ours) {
            Write-Utf8 $Path $persona
            Write-Host "install-context.ps1: refreshed SOUL.md"
            return
        }
    }
    Write-Utf8 $Path $persona
    Write-Host "install-context.ps1: wrote SOUL.md"
}

if (-not (Test-Path -LiteralPath $Persona) -or -not (Test-Path -LiteralPath $Section)) {
    throw "install-context.ps1: missing PERSONA.md or context section."
}

if ($HomeDir) {
    New-Item -ItemType Directory -Force -Path $HomeDir | Out-Null
    Set-HomeSoul (Join-Path $HomeDir "SOUL.md")
    Set-AgentsSection (Join-Path $HomeDir "AGENTS.md")
    Write-Host "install-context.ps1: AGENTS.md section is in $HomeDir"
    return
}

$id = docker compose -f $ComposeFile ps -q $Service 2>$null
if (-not $id) {
    throw "install-context.ps1: Compose agent is not running. Start it with scripts/install.ps1, or pass -Home HERMES_HOME."
}

$remote = docker compose -f $ComposeFile exec -T -u 0 $Service sh -c "if test -f /var/lib/hermes/AGENTS.md; then cat /var/lib/hermes/AGENTS.md; fi"
if ($LASTEXITCODE -ne 0) { throw "install-context.ps1: could not read AGENTS.md in the container" }

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("cat-paw-context-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $stage | Out-Null
try {
    $agents = Join-Path $stage "AGENTS.md"
    if ($remote) {
        $text = if ($remote -is [array]) { $remote -join "`n" } else { [string]$remote }
        if ($text.Trim().Length -gt 0) {
            if (-not $text.EndsWith("`n")) { $text += "`n" }
            Write-Utf8 $agents $text
        }
    }
    Set-AgentsSection $agents
    tar -C $stage -cf - AGENTS.md | docker compose -f $ComposeFile exec -T -u 0 $Service tar -C /var/lib/hermes -xf -
    if ($LASTEXITCODE -ne 0) { throw "install-context.ps1: could not write AGENTS.md into the container" }
    docker compose -f $ComposeFile exec -T -u 0 $Service chmod 0644 /var/lib/hermes/AGENTS.md
    if ($LASTEXITCODE -ne 0) { throw "install-context.ps1: chmod AGENTS.md failed" }
}
finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "install-context.ps1: appended the Cat Paw section to AGENTS.md"
Write-Host "install-context.ps1: SOUL.md is PERSONA.md, composed on boot after the base persona"
