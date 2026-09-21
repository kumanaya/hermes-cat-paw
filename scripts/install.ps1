# Provision Hermes Cat Paw: reuse an existing Plow login and free line when
# present. With no -Line, mint the first free dashboard name automatically.
# Do not create a new assistant line unless -NewLine is passed.
param(
    [string]$Line,
    [switch]$NewLine
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Tools = Join-Path $Root ".tools\plow-agents"
$Credentials = Join-Path $Root "plow-credentials"
$Cli = Join-Path $Tools "bin\plow-agents"
$TokenHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$TokenFile = Join-Path $TokenHome "plow\token"
# Agent Index identity for this product. Never inherit a host AGENT_ID.
$env:AGENT_ID = "hermes-cat-paw"

function Ensure-Cli {
    if (-not (Test-Path -LiteralPath (Join-Path $Tools ".git"))) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Tools) | Out-Null
        git clone https://github.com/plow-pbc/plow-agents.git $Tools
    }
}

function Invoke-PlowLogin {
    if ($NewLine) {
        Write-Host "Provisioning a new assistant line (phone SMS)."
        python $Cli login --new-line
    } else {
        python $Cli login
    }
}

function Test-AccountToken {
    return (Test-Path -LiteralPath $TokenFile -PathType Leaf) -and ((Get-Item -LiteralPath $TokenFile).Length -gt 0)
}

function Get-PlowLines {
    $rows = @()
    $output = python $Cli lines 2>&1
    foreach ($raw in $output) {
        $text = "$raw"
        if ($text -notmatch "`t") { continue }
        $parts = $text -split "`t", 4
        if ($parts.Count -lt 4) { continue }
        if ($parts[0] -eq "LINE") { continue }
        $rows += [pscustomobject]@{
            Uid    = $parts[0]
            Name   = $parts[1]
            Number = $parts[2]
            Status = $parts[3]
        }
    }
    return $rows
}

function Get-FreeLines {
    return @(Get-PlowLines | Where-Object { $_.Status -eq "free" })
}

function Write-FreeNames {
    $free = Get-FreeLines
    if (-not $free -or $free.Count -eq 0) {
        Write-Host "  (none)"
        return
    }
    foreach ($row in $free) {
        Write-Host "  $($row.Name)"
    }
}

function Resolve-Line([string]$Query) {
    $all = @(Get-PlowLines)
    foreach ($row in $all) {
        if ($row.Uid -eq $Query -or $row.Name -eq $Query) { return $row }
        if ($row.Uid.ToLower() -eq $Query.ToLower() -or $row.Name.ToLower() -eq $Query.ToLower()) {
            return $row
        }
    }
    $index = 0
    if ([int]::TryParse($Query, [ref]$index)) {
        $free = Get-FreeLines
        if ($index -ge 1 -and $index -le $free.Count) {
            return $free[$index - 1]
        }
    }
    return $null
}

function Invoke-MintFreeLine([string]$Query) {
    $row = Resolve-Line $Query
    if ($null -eq $row) {
        Write-Error "install.ps1: unknown line '$Query'. Free lines:"
        Write-FreeNames
        throw "Unknown line."
    }
    if ($row.Status -ne "free") {
        Write-Error "install.ps1: $($row.Name) already has an assistant assigned. Delete that agent in Plow, pick a free line, or pass -NewLine."
        Write-Host "Free lines:"
        Write-FreeNames
        throw "Line is not free."
    }
    Write-Host "Minting free line $($row.Name)."
    python $Cli mint $row.Uid
}

if (Test-Path -LiteralPath $Credentials -PathType Container) {
    if (Get-ChildItem -Force -LiteralPath $Credentials) {
        throw "install.ps1: plow-credentials is a non-empty directory. That usually means docker compose ran before mint. Move it aside and re-run."
    }
    Write-Host "install.ps1: removing empty plow-credentials directory left by docker compose."
    Remove-Item -LiteralPath $Credentials
}

if (Test-Path -LiteralPath $Credentials -PathType Leaf) {
    Write-Host "Using existing plow-credentials. Skipping Plow login."
} else {
    Ensure-Cli

    if ($NewLine) {
        Invoke-PlowLogin
    } elseif (Test-AccountToken) {
        Write-Host "Using existing Plow account token. Skipping phone login."
    } else {
        Write-Host "No account token yet. Logging in without creating a new line."
        Write-Host "Keep this script in the foreground. When it prints a destination number and Plow Activate: <code>, show those two lines to the owner and wait for them to reply: feito"
        Invoke-PlowLogin
    }

    $free = Get-FreeLines
    $all = @(Get-PlowLines)
    if ((-not $free -or $free.Count -eq 0) -and -not $NewLine) {
        if ($all.Count -eq 0) {
            Write-Host "This Plow account has no assistant line yet (normal on a first install)."
            Write-Host "Creating the first line — required so the agent can have a phone number."
            Write-Host "Another SMS will print. Relay it the same way and wait for: feito"
            $NewLine = $true
            Invoke-PlowLogin
            $free = Get-FreeLines
        } else {
            $occupied = @($all | Where-Object { $_.Status -ne "free" } | ForEach-Object { $_.Name })
            if ($occupied.Count -gt 0) {
                Write-Host "Already assigned: $($occupied -join ', ')"
            }
            throw "install.ps1: every line on this account already has an assistant. Do not create another unless the owner asked. Then: .\scripts\install.ps1 -NewLine"
        }
    }

    if ([string]::IsNullOrWhiteSpace($Line)) {
        $picked = @(Get-FreeLines | Sort-Object Name | Select-Object -First 1)
        if (-not $picked -or $picked.Count -eq 0) {
            throw "install.ps1: still no free Plow line after login. Ask the owner, then re-run with -NewLine, or free a line in Plow."
        }
        $Line = $picked[0].Name
        Write-Host "Free Plow lines (no assistant assigned):"
        Write-FreeNames
        Write-Host "Using free line $Line. Pass -Line NAME to override; -NewLine to create another."
    }

    Invoke-MintFreeLine $Line
}

if (-not (Test-Path -LiteralPath $Credentials -PathType Leaf)) {
    throw "install.ps1: plow-credentials is still missing after mint. Do not run docker compose up until this file exists. Re-run this script."
}

$Compose = Join-Path $Root "compose.yml"
Write-Host "Starting Compose with AGENT_ID=$($env:AGENT_ID)"
docker compose -f $Compose up --build -d
# Repair sticky-home ledger ownership, wait for state.db, and report as uid hermes.
& (Join-Path $PSScriptRoot "verify.ps1")
# Cybersecurity pack is a runtime clone, not baked into the image.
try {
    & (Join-Path $PSScriptRoot "install-skills.ps1")
} catch {
    Write-Host "install.ps1: skill packs did not land. Re-run scripts/install-skills.ps1."
}
# Last lines of the log: installing agents relay name + number. Do not skip.
Write-Host "==== tell the owner (do not skip) ===="
try {
    & (Join-Path $PSScriptRoot "announce-line.ps1")
} catch {
    Write-Host "install.ps1: could not name the line. Do not make the owner guess."
}
Write-Host "The agent is installed. The skill packs are in Hermes."
Write-Host "They text the number above from their phone."
