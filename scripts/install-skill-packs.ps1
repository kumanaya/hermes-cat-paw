# Clone the pinned extra skill packs into a Hermes home.
# Playbook text stays upstream. This script copies the pinned trees and the
# router skills from this repo. It does not relicense anything.
param(
    [Alias("Home")]
    [string]$HomeDir,
    [switch]$List
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Pin = Join-Path $Root "vendor\skill-packs.pin"
$ToolsRoot = Join-Path $Root ".tools\skill-packs"
$ComposeFile = Join-Path $Root "compose.yml"
$Service = "hermes-cat-paw"

function Read-SkillPackPin([string]$Path) {
    $routers = New-Object System.Collections.Generic.List[string]
    $packs = New-Object System.Collections.Generic.List[object]
    $cur = $null
    foreach ($raw in Get-Content -LiteralPath $Path) {
        $line = $raw.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { continue }
        $splitAt = $line.IndexOf(" ")
        if ($splitAt -lt 1) { throw "install-skill-packs.ps1: bad pin line: $line" }
        $key = $line.Substring(0, $splitAt)
        $val = $line.Substring($splitAt + 1).Trim()
        switch ($key) {
            "router" { $routers.Add($val) }
            "pack" {
                if ($null -ne $cur) { $packs.Add($cur) }
                $cur = [ordered]@{
                    id = $val; repo = ""; sha = ""; dest = ""; layout = "flat"
                    include = @(); exclude = @(); doc = @()
                }
            }
            "repo" { $cur.repo = $val }
            "sha" { $cur.sha = $val }
            "dest" { $cur.dest = $val }
            "layout" { $cur.layout = $val }
            "include" { $cur.include = @($cur.include) + $val }
            "exclude" { $cur.exclude = @($cur.exclude) + $val }
            "doc" { $cur.doc = @($cur.doc) + $val }
            default { throw "install-skill-packs.ps1: unknown pin key: $key" }
        }
    }
    if ($null -ne $cur) { $packs.Add($cur) }
    # A hashtable return unrolls nested dictionaries into the caller's pipeline.
    [pscustomobject]@{
        routers = $routers.ToArray()
        packs = $packs.ToArray()
    }
}

function Sync-PackCheckout($Pack) {
    # Several packs share one upstream repo. One checkout per URL.
    $slug = ($Pack.repo -replace '^https://github.com/', '' -replace '\.git$', '' -replace '[\\/]', '__')
    $dir = Join-Path $ToolsRoot $slug
    if (-not (Test-Path -LiteralPath (Join-Path $dir ".git"))) {
        Write-Host "install-skill-packs.ps1: cloning $($Pack.id)"
        New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null
        git clone --depth 1 $Pack.repo $dir
        if ($LASTEXITCODE -ne 0) { throw "git clone failed for $($Pack.id)" }
    }
    Write-Host "install-skill-packs.ps1: checking out $($Pack.id) $($Pack.sha)"
    git -C $dir fetch --depth 1 origin $Pack.sha
    if ($LASTEXITCODE -ne 0) { throw "git fetch failed for $($Pack.id)" }
    git -C $dir checkout --detach $Pack.sha
    if ($LASTEXITCODE -ne 0) { throw "git checkout failed for $($Pack.id)" }
    $got = (git -C $dir rev-parse HEAD).Trim()
    if ($got -ne $Pack.sha) { throw "install-skill-packs.ps1: $($Pack.id) expected $($Pack.sha), got $got" }
    return $dir
}

function Copy-OneSkill([string]$Source, [string]$DestParent, [string]$Name) {
    $target = Join-Path $DestParent $Name
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $DestParent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $target -Recurse -Force
}

function Install-OnePack($Pack, [string]$Checkout, [string]$SkillsRoot) {
    if (-not $Pack.repo -or -not $Pack.sha -or -not $Pack.dest) {
        throw "install-skill-packs.ps1: incomplete pack $($Pack.id)"
    }
    if ($Pack.layout -notin @("flat", "grouped")) {
        throw "install-skill-packs.ps1: $($Pack.id) layout must be flat or grouped"
    }
    $dest = Join-Path $SkillsRoot ($Pack.dest -replace "/", "\")
    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $skip = @{}
    foreach ($name in $Pack.exclude) { $skip[$name] = $true }

    foreach ($inc in $Pack.include) {
        $src = Join-Path $Checkout ($inc -replace "/", "\")
        if (-not (Test-Path -LiteralPath $src)) {
            throw "install-skill-packs.ps1: $($Pack.id) missing $inc"
        }
        if (Test-Path -LiteralPath (Join-Path $src "SKILL.md")) {
            Copy-OneSkill $src $dest (Split-Path -Leaf $src)
            continue
        }
        $parent = $dest
        if ($Pack.layout -eq "grouped") {
            $parent = Join-Path $dest (Split-Path -Leaf (Split-Path -Parent $src))
        }
        $children = @(Get-ChildItem -LiteralPath $src -Force | Where-Object { $_.Name -notin ".", ".." })
        $kept = 0
        $checkoutRoot = [System.IO.Path]::GetFullPath($Checkout).TrimEnd('\') + '\'
        foreach ($child in $children) {
            if ($skip.ContainsKey($child.Name)) { continue }
            $source = $child.FullName
            $skillFile = Join-Path $source "SKILL.md"
            if (-not (Test-Path -LiteralPath $skillFile)) {
                # Git symlink checked out as a text file (Windows, core.symlinks=false).
                if ($child.PSIsContainer -or $child.Length -gt 200) { continue }
                $raw = (Get-Content -LiteralPath $source -Raw).Trim()
                if ($raw -match '[\r\n]' -or $raw -notmatch '^(\.\./|\./)?[A-Za-z0-9_./-]+$') { continue }
                $linked = [System.IO.Path]::GetFullPath((Join-Path $src ($raw -replace "/", "\")))
                if (-not ($linked + '\').StartsWith($checkoutRoot, [StringComparison]::OrdinalIgnoreCase)) { continue }
                if (-not (Test-Path -LiteralPath (Join-Path $linked "SKILL.md"))) { continue }
                $source = $linked
            }
            Copy-OneSkill $source $parent $child.Name
            $kept++
        }
        if ($kept -eq 0) {
            throw "install-skill-packs.ps1: $($Pack.id) $inc has no SKILL.md children"
        }
    }

    foreach ($doc in $Pack.doc) {
        $from = Join-Path $Checkout $doc
        if (Test-Path -LiteralPath $from) {
            Copy-Item -LiteralPath $from -Destination (Join-Path $dest $doc) -Force
        } else {
            throw "install-skill-packs.ps1: $($Pack.id) missing doc $doc"
        }
    }

    return @(Get-ChildItem -LiteralPath $dest -Filter SKILL.md -Recurse -File).Count
}

function Copy-Routers([string[]]$Routers, [string]$SkillsRoot) {
    foreach ($name in $Routers) {
        $from = Join-Path $Root "skills\$name"
        if (-not (Test-Path -LiteralPath (Join-Path $from "SKILL.md"))) {
            throw "install-skill-packs.ps1: missing router skills/$name/SKILL.md"
        }
        $target = Join-Path $SkillsRoot $name
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        Copy-Item -LiteralPath $from -Destination $target -Recurse -Force
    }
}

$parsed = Read-SkillPackPin $Pin
$counts = @()
foreach ($pack in $parsed.packs) {
    $checkout = Sync-PackCheckout $pack
    if ($List) {
        Write-Host "install-skill-packs.ps1: listed $($pack.id) at $($pack.sha)"
        continue
    }
    $counts += [pscustomobject]@{ id = $pack.id; dest = $pack.dest; checkout = $checkout; pack = $pack }
}

if ($List) { return }

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("skill-packs-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $stage | Out-Null
try {
    foreach ($row in $counts) {
        $n = Install-OnePack $row.pack $row.checkout $stage
        Write-Host "install-skill-packs.ps1: $($row.id) -> $($row.dest) ($n SKILL.md)"
    }
    Copy-Routers @($parsed.routers) $stage

    if ($HomeDir) {
        $skills = Join-Path $HomeDir "skills"
        New-Item -ItemType Directory -Force -Path $skills | Out-Null
        Copy-Item -Path (Join-Path $stage "*") -Destination $skills -Recurse -Force
        Write-Host "install-skill-packs.ps1: wrote $skills"
        return
    }

    $id = docker compose -f $ComposeFile ps -q $Service 2>$null
    if (-not $id) {
        throw "install-skill-packs.ps1: Compose agent is not running. Start it with scripts/install.ps1, or pass -Home HERMES_HOME."
    }
    $paths = @($parsed.packs | ForEach-Object { $_.dest }) + @($parsed.routers)
    foreach ($rel in $paths) {
        $remote = "/var/lib/hermes/skills/" + ($rel -replace "\\", "/")
        docker compose -f $ComposeFile exec -T -u 0 $Service rm -rf $remote
        if ($LASTEXITCODE -ne 0) { throw "rm $remote failed" }
    }
    docker compose -f $ComposeFile exec -T -u 0 $Service mkdir -p /var/lib/hermes/skills
    tar -C $stage -cf - . |
        docker compose -f $ComposeFile exec -T -u 0 $Service tar -C /var/lib/hermes/skills -xf -
    if ($LASTEXITCODE -ne 0) { throw "tar into container failed" }
    docker compose -f $ComposeFile exec -T -u 0 $Service chown -R hermes:hermes /var/lib/hermes/skills
    Write-Host "install-skill-packs.ps1: copied packs into the Compose agent"
}
finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
