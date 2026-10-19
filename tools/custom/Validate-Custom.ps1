[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location $root
try {
    $branch = & git branch --show-current
    if ($LASTEXITCODE -ne 0 -or $branch -ne 'custom') { throw 'Validation must run on custom.' }
    $unmerged = & git diff --name-only --diff-filter=U
    if ($LASTEXITCODE -ne 0 -or $unmerged) { throw 'Resolve all unmerged index entries before validation.' }
    & git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'Resolve whitespace errors or conflict markers before validation.' }
    & git diff --cached --check
    if ($LASTEXITCODE -ne 0) { throw 'Resolve staged whitespace errors or conflict markers before validation.' }
    foreach ($command in @('lint:check','typecheck','test:run','build')) {
        Write-Output "Validating frontend: $command"
        if ($env:OS -eq 'Windows_NT') {
            & (Join-Path $root 'tools/pnpm.cmd') run $command
        } else {
            & sh (Join-Path $root 'tools/pnpm.sh') run $command
        }
        if ($LASTEXITCODE -ne 0) { throw "Frontend validation failed: $command (exit $LASTEXITCODE)" }
    }
    & (Join-Path $root 'deploy/custom/Test-Configuration.ps1')
    Write-Output 'Frontend and Compose checks passed. Docker image/runtime, migration recovery, browser and payment acceptance remain separate steps.'
} finally {
    Pop-Location
}
