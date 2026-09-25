# Clone the pinned extra skill packs into a Hermes home.
# Playbook text stays upstream. This script copies the pinned trees and the
# router skills from this repo. It does not relicense anything.
param(
    [Alias("Home")]
    [string]$HomeDir,
    [switch]$List,
    [switch]$RoutersOnly
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

function Test-SafeRelativePath([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value.Contains("`r") -or $Value.Contains("`n")) { return $false }
    if ($Value.Contains("..")) { return $false }
    if ($Value.Contains("\")) { return $false }
    if ($Value.StartsWith([string]"/", [System.StringComparison]::Ordinal)) { return $false }
    if ($Value -match "^[A-Za-z]:") { return $false }
    if ($Value.StartsWith([string]"~", [System.StringComparison]::Ordinal)) { return $false }
    if ($Value.Contains("//") -or $Value.EndsWith([string]"/", [System.StringComparison]::Ordinal)) { return $false }
    $parts = $Value.Split([char]"/")
    foreach ($part in $parts) {
        if ([string]::IsNullOrEmpty($part) -or $part -eq "." -or $part -eq "..") {
            return $false
        }
    }
    return $true
}

function Get-ResolvedLocalPath([string]$Path, [int]$Depth = 0) {
    if ($Depth -gt 32) { throw "install-skill-packs.ps1: symlink resolution exceeded 32 levels" }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    $targetProperty = $item.PSObject.Properties["Target"]
    if ($null -ne $targetProperty -and $null -ne $targetProperty.Value) {
        $target = [string](@($targetProperty.Value)[0])
        if (-not [string]::IsNullOrWhiteSpace($target)) {
            if (-not [System.IO.Path]::IsPathRooted($target)) {
                $target = Join-Path (Split-Path -Parent $item.FullName) $target
            }
            return (Get-ResolvedLocalPath -Path $target -Depth ($Depth + 1))
        }
    }
    return [System.IO.Path]::GetFullPath($item.FullName)
}

function Test-PathInside([string]$Root, [string]$Candidate) {
    $rootFull = [System.IO.Path]::GetFullPath($Root)
    $candidateFull = [System.IO.Path]::GetFullPath($Candidate)
    $rootPrefix = $rootFull.TrimEnd([char[]]@('\', '/')) + [System.IO.Path]::DirectorySeparatorChar
    return ($candidateFull.Equals($rootFull, [System.StringComparison]::OrdinalIgnoreCase) -or
        $candidateFull.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase))
}

function Get-ContainedDestinationPath([string]$Root, [string]$Candidate) {
    $rootResolved = Get-ResolvedLocalPath $Root
    if (-not (Test-PathInside $rootResolved $Candidate)) { return $null }
    $candidateItem = Get-Item -LiteralPath $Candidate -Force -ErrorAction SilentlyContinue
    if ($null -ne $candidateItem) {
        $candidateResolved = Get-ResolvedLocalPath $Candidate
    } else {
        $parentResolved = Get-ResolvedLocalPath (Split-Path -Parent $Candidate)
        $candidateResolved = Join-Path $parentResolved (Split-Path -Leaf $Candidate)
    }
    if (-not (Test-PathInside $rootResolved $candidateResolved)) { return $null }
    return $candidateResolved
}

function Validate-SkillPackPin($Parsed) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root "LICENSE") -PathType Leaf)) {
        throw "install-skill-packs.ps1: missing project LICENSE"
    }
    if (@($Parsed.routers).Count -eq 0) {
        throw "install-skill-packs.ps1: pin has no routers"
    }
    $routerSeen = @{}
    foreach ($name in @($Parsed.routers)) {
        if (-not (Test-SafeRelativePath $name) -or $name.Contains("/") -or $name.Contains("\")) {
            throw "install-skill-packs.ps1: invalid router $name"
        }
        if ($routerSeen.ContainsKey($name)) {
            throw "install-skill-packs.ps1: duplicate router $name"
        }
        $routerSeen[$name] = $true
        if (-not (Test-Path -LiteralPath (Join-Path $Root "skills\$name\SKILL.md") -PathType Leaf)) {
            throw "install-skill-packs.ps1: missing router skills/$name/SKILL.md"
        }
    }
    $packSeen = @{}
    $destSeen = @{}
    foreach ($pack in @($Parsed.packs)) {
        if (-not $pack.id -or -not $pack.repo -or -not $pack.sha -or -not $pack.dest) {
            throw "install-skill-packs.ps1: incomplete pack $($pack.id)"
        }
        if ($packSeen.ContainsKey($pack.id)) {
            throw "install-skill-packs.ps1: duplicate pack $($pack.id)"
        }
        $packSeen[$pack.id] = $true
        if ($pack.dest -eq "." -or -not (Test-SafeRelativePath $pack.dest) -or $destSeen.ContainsKey($pack.dest)) {
            throw "install-skill-packs.ps1: invalid or duplicate destination $($pack.dest)"
        }
        $destSeen[$pack.dest] = $true
        if ($pack.layout -notin @("flat", "grouped")) {
            throw "install-skill-packs.ps1: $($pack.id) layout must be flat or grouped"
        }
        if (@($pack.include).Count -eq 0) {
            throw "install-skill-packs.ps1: $($pack.id) has no include paths"
        }
        foreach ($include in @($pack.include)) {
            if (-not (Test-SafeRelativePath $include)) {
                throw "install-skill-packs.ps1: invalid include $include"
            }
        }
        foreach ($doc in @($pack.doc)) {
            if (-not (Test-SafeRelativePath $doc) -or $doc.Contains("/") -or $doc.Contains("\")) {
                throw "install-skill-packs.ps1: invalid doc $doc"
            }
        }
    }
}

function Sync-PackCheckout($Pack) {
    # Several packs share one upstream repo. One checkout per URL.
    $slug = ($Pack.repo -replace '^https://github.com/', '' -replace '\.git$', '' -replace '[\\/]', '__')
    $dir = Join-Path $ToolsRoot $slug
    if (-not (Test-Path -LiteralPath (Join-Path $dir ".git"))) {
        Write-Host "install-skill-packs.ps1: cloning $($Pack.id)"
        New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null
        & git clone --depth 1 $Pack.repo $dir | Out-Host
        $cloneExit = $LASTEXITCODE
        if ($cloneExit -ne 0) { throw "git clone failed for $($Pack.id)" }
    }
    Write-Host "install-skill-packs.ps1: checking out $($Pack.id) $($Pack.sha)"
    & git -C $dir fetch --depth 1 origin $Pack.sha | Out-Host
    $fetchExit = $LASTEXITCODE
    if ($fetchExit -ne 0) { throw "git fetch failed for $($Pack.id)" }
    & git -C $dir checkout --detach $Pack.sha | Out-Host
    $checkoutExit = $LASTEXITCODE
    if ($checkoutExit -ne 0) { throw "git checkout failed for $($Pack.id)" }
    $revParseOutput = @(& git -C $dir rev-parse HEAD 2>&1)
    $revParseExit = $LASTEXITCODE
    if ($revParseExit -ne 0) { throw "git rev-parse failed for $($Pack.id)" }
    $got = ($revParseOutput -join "`n").Trim()
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
    if ($Pack.dest -eq "." -or -not (Test-SafeRelativePath $Pack.dest)) {
        throw "install-skill-packs.ps1: invalid destination $($Pack.dest)"
    }
    if ($Pack.layout -notin @("flat", "grouped")) {
        throw "install-skill-packs.ps1: $($Pack.id) layout must be flat or grouped"
    }
    $dest = Join-Path $SkillsRoot ($Pack.dest -replace "/", "\")
    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $skillsRootResolved = Get-ResolvedLocalPath $SkillsRoot
    $destResolved = Get-ResolvedLocalPath $dest
    if (-not (Test-PathInside $skillsRootResolved $destResolved)) {
        throw "install-skill-packs.ps1: $($Pack.id) destination escapes skills root"
    }
    $skip = @{}
    foreach ($name in $Pack.exclude) { $skip[$name] = $true }

    foreach ($inc in $Pack.include) {
        if (-not (Test-SafeRelativePath $inc)) {
            throw "install-skill-packs.ps1: invalid include $inc"
        }
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

    $checkoutResolved = Get-ResolvedLocalPath $Checkout
    foreach ($doc in $Pack.doc) {
        if (-not (Test-SafeRelativePath $doc) -or $doc.Contains("/") -or $doc.Contains("\")) {
            throw "install-skill-packs.ps1: invalid doc $doc"
        }
        $from = Join-Path $Checkout $doc
        if (-not (Test-Path -LiteralPath $from -PathType Leaf)) {
            throw "install-skill-packs.ps1: $($Pack.id) missing doc $doc"
        }
        $fromResolved = Get-ResolvedLocalPath $from
        if (-not (Test-PathInside $checkoutResolved $fromResolved)) {
            throw "install-skill-packs.ps1: $($Pack.id) doc escapes checkout: $doc"
        }
        $docDest = Join-Path $dest $doc
        if ($null -eq (Get-ContainedDestinationPath $destResolved $docDest)) {
            throw "install-skill-packs.ps1: $($Pack.id) doc escapes destination: $doc"
        }
        if (Test-Path -LiteralPath $docDest -PathType Container) {
            throw "install-skill-packs.ps1: $($Pack.id) doc destination is a directory: $doc"
        }
        Copy-Item -LiteralPath $from -Destination $docDest -Force
        if ($null -eq (Get-ContainedDestinationPath $destResolved $docDest)) {
            throw "install-skill-packs.ps1: $($Pack.id) doc copy escaped destination: $doc"
        }
    }

    $count = @(Get-ChildItem -LiteralPath $dest -Filter SKILL.md -Recurse -File).Count
    if ($count -eq 0) {
        throw "install-skill-packs.ps1: $($Pack.id) installed zero SKILL.md files"
    }
    return $count
}

function Copy-Routers([string[]]$Routers, [string]$SkillsRoot) {
    New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
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
    Copy-Item -LiteralPath (Join-Path $Root "LICENSE") -Destination (Join-Path $SkillsRoot "LICENSE.hermes-cat-paw") -Force
}

function Remove-ManagedPaths([string]$SkillsRoot, [bool]$IncludePacks, $Parsed) {
    New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
    foreach ($name in @($Parsed.routers)) {
        $target = Join-Path $SkillsRoot $name
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
    }
    if ($IncludePacks) {
        foreach ($pack in @($Parsed.packs)) {
            $target = Join-Path $SkillsRoot ($pack.dest -replace "/", "\")
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Recurse -Force
            }
        }
    }
    $license = Join-Path $SkillsRoot "LICENSE.hermes-cat-paw"
    if (Test-Path -LiteralPath $license) {
        Remove-Item -LiteralPath $license -Force
    }
}

if ($List -and $RoutersOnly) {
    throw "install-skill-packs.ps1: -List and -RoutersOnly cannot be combined"
}

$parsed = Read-SkillPackPin $Pin
Validate-SkillPackPin $parsed

if ($List) {
    foreach ($pack in $parsed.packs) {
        $null = Sync-PackCheckout $pack
        Write-Host "install-skill-packs.ps1: listed $($pack.id) at $($pack.sha)"
    }
    return
}

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("skill-packs-" + [guid]::NewGuid().ToString("n"))
$archive = $null
New-Item -ItemType Directory -Force -Path $stage | Out-Null
try {
    if ($RoutersOnly) {
        Copy-Routers @($parsed.routers) $stage
    } else {
        foreach ($pack in $parsed.packs) {
            $checkout = Sync-PackCheckout $pack
            $n = Install-OnePack $pack $checkout $stage
            Write-Host "install-skill-packs.ps1: $($pack.id) -> $($pack.dest) ($n SKILL.md)"
        }
        Copy-Routers @($parsed.routers) $stage
    }

    if ($HomeDir) {
        $skills = Join-Path $HomeDir "skills"
        Remove-ManagedPaths $skills (-not $RoutersOnly) $parsed
        Copy-Item -Path (Join-Path $stage "*") -Destination $skills -Recurse -Force
        Write-Host "install-skill-packs.ps1: wrote $skills"
        return
    }

    $containerIds = @(docker compose -f $ComposeFile ps -q $Service 2>$null)
    $composeInspectExit = $LASTEXITCODE
    if ($composeInspectExit -ne 0) { throw "install-skill-packs.ps1: could not inspect Compose" }
    if ($containerIds.Count -eq 0 -or [string]::IsNullOrWhiteSpace([string]$containerIds[0])) {
        throw "install-skill-packs.ps1: Compose agent is not running. Start it with scripts/install.ps1, or pass -Home HERMES_HOME."
    }
    $containerId = ([string]$containerIds[0]).Trim()
    $paths = @($parsed.routers)
    if (-not $RoutersOnly) {
        $paths += @($parsed.packs | ForEach-Object { $_.dest })
    }
    foreach ($rel in $paths) {
        $remote = "/var/lib/hermes/skills/" + ($rel -replace "\\", "/")
        docker compose -f $ComposeFile exec -T -u 0 $Service rm -rf $remote
        if ($LASTEXITCODE -ne 0) { throw "rm $remote failed" }
    }
    docker compose -f $ComposeFile exec -T -u 0 $Service rm -f /var/lib/hermes/skills/LICENSE.hermes-cat-paw
    if ($LASTEXITCODE -ne 0) { throw "rm Cat Paw license failed" }
    docker compose -f $ComposeFile exec -T -u 0 $Service mkdir -p /var/lib/hermes/skills
    if ($LASTEXITCODE -ne 0) { throw "mkdir skills failed" }

    $archive = Join-Path ([System.IO.Path]::GetTempPath()) ("hermes-skill-packs-" + [guid]::NewGuid().ToString("n") + ".tar")
    $remoteArchive = "/tmp/hermes-skill-packs-" + [guid]::NewGuid().ToString("n") + ".tar"
    try {
        & tar -C $stage -cf $archive .
        $archiveExit = $LASTEXITCODE
        if ($archiveExit -ne 0) { throw "install-skill-packs.ps1: tar archive creation failed" }
        & docker cp $archive ($containerId + ":" + $remoteArchive)
        $copyExit = $LASTEXITCODE
        if ($copyExit -ne 0) { throw "install-skill-packs.ps1: docker cp failed" }
        docker compose -f $ComposeFile exec -T -u 0 $Service tar -C /var/lib/hermes/skills -xf $remoteArchive
        $extractExit = $LASTEXITCODE
        if ($extractExit -ne 0) { throw "install-skill-packs.ps1: tar extraction failed" }
    }
    finally {
        docker compose -f $ComposeFile exec -T -u 0 $Service rm -f $remoteArchive
        $remoteRemoveExit = $LASTEXITCODE
        if ($remoteRemoveExit -ne 0) { throw "install-skill-packs.ps1: remote archive removal failed" }
    }
    docker compose -f $ComposeFile exec -T -u 0 $Service chown -R hermes:hermes /var/lib/hermes/skills
    if ($LASTEXITCODE -ne 0) { throw "chown skills failed" }
    Write-Host "install-skill-packs.ps1: copied packs into the Compose agent"
}
finally {
    if (-not [string]::IsNullOrWhiteSpace($archive)) {
        Remove-Item -LiteralPath $archive -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
