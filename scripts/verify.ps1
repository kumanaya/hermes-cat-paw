# Confirm the Compose agent reports as hermes-cat-paw. Always exec the Index
# client as uid hermes — docker compose exec defaults to root and that breaks
# the sticky HERMES_HOME ledger.
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$ComposeFile = Join-Path $Root "compose.yml"
$Service = "hermes-cat-paw"
$Python = "/opt/hermes/.venv/bin/python3"
$Client = "/opt/plow/agent-index-client.py"

function Invoke-Compose {
    docker compose -f $ComposeFile @args
    if ($LASTEXITCODE -ne 0) { throw "docker compose failed: $args" }
}

$id = docker compose -f $ComposeFile ps -q $Service 2>$null
if (-not $id) {
    throw "verify: container is not running. Start it with scripts/install.ps1."
}

Write-Host "verify: repairing Index ledger ownership (sticky HERMES_HOME)"
Invoke-Compose exec -T -u 0 $Service sh -c @'
  for f in /var/lib/hermes/.agent-index-state.json \
           /var/lib/hermes/.agent-index-state.json.new \
           /var/lib/hermes/.agent-index.json \
           /var/lib/hermes/.agent-index.lock; do
    [ -e "$f" ] || continue
    chown hermes:hermes "$f"
  done
  idf=/run/s6/container_environment/AGENT_ID
  if [ -r "$idf" ]; then
    got=$(cat "$idf")
    echo "verify: container AGENT_ID=$got"
    [ "$got" = "hermes-cat-paw" ] || exit 1
  fi
'@

Write-Host "verify: waiting for Hermes state.db"
$n = 0
do {
    docker compose -f $ComposeFile exec -T -u hermes $Service sh -c "test -s /var/lib/hermes/state.db"
    if ($LASTEXITCODE -eq 0) { break }
    $n++
    if ($n -gt 60) { throw "verify: state.db did not appear" }
    Start-Sleep -Seconds 2
} while ($true)

function Invoke-HermesClient {
    docker compose -f $ComposeFile exec -T -u hermes `
        -e HOME=/var/lib/hermes `
        -e HERMES_HOME=/var/lib/hermes `
        -e AGENT_ID=hermes-cat-paw `
        $Service $Python $Client @args
}

function Register-Page {
    $token = docker compose -f $ComposeFile exec -T -u 0 $Service sh -c 'cat /run/s6/container_environment/PLOW_AGENT_TOKEN'
    docker compose -f $ComposeFile exec -T -u hermes `
        -e HOME=/var/lib/hermes `
        -e HERMES_HOME=/var/lib/hermes `
        -e AGENT_ID=hermes-cat-paw `
        -e PLOW_AGENT_TOKEN="$token" `
        $Service $Python $Client `
        --register --agent hermes-cat-paw `
        --name "Hermes Cat Paw" `
        --blurb "Authorized recon from your phone. Latch approves every command and browser session on the computer you own." `
        --runtime "Hermes / Plow Latch" `
        --repo "https://github.com/kumanaya/hermes-cat-paw" `
        --install-url "https://github.com/kumanaya/hermes-cat-paw/blob/main/docs/INSTALL.md" `
        --video "KjWFtHh0EFE" `
        --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/hackathon-banner.png" `
        --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/images/cybersecurity.png" `
        --image "https://raw.githubusercontent.com/kumanaya/hermes-cat-paw/main/docs/images/real-usage.png"
}

Write-Host "verify: Index client as uid hermes (never root)"
Write-Host "verify: --self-check uses throwaway /tmp dirs; 'unreadable' there is expected."
Write-Host "verify: 'agentsview not installed' is optional in this image. Hermes state.db is what counts."
Invoke-HermesClient --self-check
if ($LASTEXITCODE -ne 0) { throw "verify: --self-check failed" }
Invoke-HermesClient status
$status = $LASTEXITCODE
Write-Host "verify: status exit $status (0=registered, 3=unregistered)"
if ($status -eq 3) {
    Write-Host "verify: not registered yet — registering now (do not wait for the 5-minute loop)"
    Register-Page
    if ($LASTEXITCODE -eq 0) {
        Invoke-HermesClient status
        $status = $LASTEXITCODE
    }
}
if ($status -ne 0 -and $status -ne 3) { throw "verify: Index status failed ($status)" }
Invoke-HermesClient --agent hermes-cat-paw --dry-run
if ($LASTEXITCODE -ne 0) { throw "verify: --dry-run failed" }

Write-Host "verify: reporting current usage as hermes"
Invoke-HermesClient --agent hermes-cat-paw
if ($LASTEXITCODE -ne 0) { throw "verify: live report failed. Check docker compose logs hermes-cat-paw" }

if ($status -eq 0) {
    Write-Host "verify: container OK, usage heartbeat signed in."
    Write-Host "verify: days=0 / tokens=0 is normal before a real Hermes chat."
} else {
    Write-Host "verify: container OK, usage heartbeat not signed in yet. It retries on its own. This is not a failed install."
}
$pack = docker compose -f $ComposeFile exec -T -u hermes $Service sh -c 'find /var/lib/hermes/skills/cybersecurity-skills -name SKILL.md -type f 2>/dev/null | wc -l'
Write-Host "verify: cybersecurity-skills pack=$($pack.Trim()) (run scripts/install-skills.ps1 if this is 0)"
Write-Host "verify: baked review CLIs"
docker compose -f $ComposeFile exec -T -u hermes $Service /opt/cat-paw/verify-review-tools.sh
if ($LASTEXITCODE -ne 0) { throw "verify: review CLIs missing. Rebuild the image (scripts/install.ps1)." }
Write-Host "verify: do not docker compose exec the Index client as root; use this script or -u hermes."
try {
    & (Join-Path $PSScriptRoot "announce-line.ps1")
} catch {
    Write-Host "verify: could not name the line. Do not make the owner guess."
}
