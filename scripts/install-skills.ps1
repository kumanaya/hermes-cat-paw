# Load the pinned Anthropic Cybersecurity Skills pack into a Hermes home.
# Default destination is the running Compose agent's /var/lib/hermes.
param(
    [Alias("Home")]
    [string]$HomeDir,
    [switch]$List
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Pin = Join-Path $Root "vendor\cybersecurity-skills.pin"
$Tools = Join-Path $Root ".tools\cybersecurity-skills"
$ComposeFile = Join-Path $Root "compose.yml"
$Service = "hermes-cat-paw"
$PackName = "cybersecurity-skills"
$Docs = @("LICENSE", "SECURITY.md", "SCOPE.md", "AGENTS.md", "README.md", "index.json")

$repo = $null
$sha = $null
Get-Content -LiteralPath $Pin | ForEach-Object {
    if ($_ -match '^repo=(.+)$') { $repo = $Matches[1].Trim() }
    if ($_ -match '^sha=(.+)$') { $sha = $Matches[1].Trim() }
}
if (-not $repo -or -not $sha) { throw "install-skills.ps1: malformed $Pin" }

if (-not (Test-Path -LiteralPath (Join-Path $Tools ".git"))) {
    Write-Host "install-skills.ps1: cloning cybersecurity-skills"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Tools) | Out-Null
    git clone --depth 1 $repo $Tools
    if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
}
$sparse = Join-Path $Tools ".git\info\sparse-checkout"
if (Test-Path -LiteralPath $sparse) {
    git -C $Tools sparse-checkout disable
}
Write-Host "install-skills.ps1: checking out $sha"
git -C $Tools fetch --depth 1 origin $sha
if ($LASTEXITCODE -ne 0) { throw "git fetch failed" }
git -C $Tools checkout --detach $sha
if ($LASTEXITCODE -ne 0) { throw "git checkout failed" }
$got = (git -C $Tools rev-parse HEAD).Trim()
if ($got -ne $sha) { throw "install-skills.ps1: expected $sha, got $got" }

$skillsRoot = Join-Path $Tools "skills"
if (-not (Test-Path -LiteralPath $skillsRoot)) {
    throw "install-skills.ps1: missing skills/ in checkout"
}

$skillFiles = @(Get-ChildItem -LiteralPath $skillsRoot -Filter SKILL.md -Recurse -File)
$n = $skillFiles.Count
Write-Host "install-skills.ps1: $n SKILL.md files at $sha"
Write-Host "install-skills.ps1: skills per subdomain (frontmatter):"
$skillFiles |
    ForEach-Object {
        $sub = $null
        foreach ($line in Get-Content -LiteralPath $_.FullName -TotalCount 40) {
            if ($line -match '^subdomain:\s*(.+)$') {
                $sub = $Matches[1].Trim().Trim("`"'")
                break
            }
        }
        if (-not $sub) { $sub = "(none)" }
        $sub
    } |
    Group-Object |
    Sort-Object Count -Descending |
    ForEach-Object { "{0,4}  {1}" -f $_.Count, $_.Name }

if ($List) {
    & (Join-Path $PSScriptRoot "install-skill-packs.ps1") -List
    return
}

function Copy-Docs([string]$Dest) {
    foreach ($name in $Docs) {
        $from = Join-Path $Tools $name
        if (Test-Path -LiteralPath $from) {
            Copy-Item -LiteralPath $from -Destination (Join-Path $Dest $name) -Force
        }
    }
}

$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("cybersecurity-skills-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $stage | Out-Null
try {
    Copy-Item -Path (Join-Path $skillsRoot "*") -Destination $stage -Recurse -Force
    Copy-Docs $stage

    if ($HomeDir) {
        $dest = Join-Path $HomeDir "skills\$PackName"
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        Copy-Item -Path (Join-Path $stage "*") -Destination $dest -Recurse -Force
        Write-Host "install-skills.ps1: wrote $dest ($n skills)"
        & (Join-Path $PSScriptRoot "install-skill-packs.ps1") -HomeDir $HomeDir
        & (Join-Path $PSScriptRoot "install-context.ps1") -HomeDir $HomeDir
        return
    }

    $id = docker compose -f $ComposeFile ps -q $Service 2>$null
    if (-not $id) {
        throw "install-skills.ps1: Compose agent is not running. Start it with scripts/install.ps1, or pass -Home HERMES_HOME."
    }

    Write-Host "install-skills.ps1: copying pack into the Compose agent"
    docker compose -f $ComposeFile exec -T -u 0 $Service mkdir -p "/var/lib/hermes/skills/$PackName"
    if ($LASTEXITCODE -ne 0) { throw "mkdir $PackName failed" }
    tar -C $stage -cf - . |
        docker compose -f $ComposeFile exec -T -u 0 $Service tar -C "/var/lib/hermes/skills/$PackName" -xf -
    if ($LASTEXITCODE -ne 0) { throw "tar into container failed" }
    docker compose -f $ComposeFile exec -T -u 0 $Service chown -R hermes:hermes "/var/lib/hermes/skills/$PackName"
    $landed = docker compose -f $ComposeFile exec -T -u hermes $Service sh -c "find /var/lib/hermes/skills/$PackName -name SKILL.md -type f | wc -l"
    Write-Host "install-skills.ps1: container pack has $($landed.Trim()) SKILL.md files"
    Write-Host "install-skills.ps1: authorized testing only. Live probes go through Latch."
    & (Join-Path $PSScriptRoot "install-skill-packs.ps1")
    & (Join-Path $PSScriptRoot "install-context.ps1")
}
finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
