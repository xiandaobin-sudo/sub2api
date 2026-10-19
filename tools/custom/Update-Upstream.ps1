[CmdletBinding()]
param(
    [ValidateSet('Inspect','UpdateMain','Merge')][string]$Step = 'Inspect',
    [string]$Ref,
    [switch]$Fetch
)
$ErrorActionPreference = 'Stop'
function Run-Git {
    & git @args
    if ($LASTEXITCODE -ne 0) { throw "git failed (exit $LASTEXITCODE): $args" }
}
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location $root
try {
    if ((Run-Git branch --show-current) -ne 'custom') { throw 'Run this workflow from custom.' }
    if ($Step -ne 'Inspect' -and @(Run-Git status --porcelain).Count -gt 0) {
        throw 'Working tree/index is not clean. Save and review your changes first; nothing was changed.'
    }
    if ($Fetch) { Run-Git fetch upstream --tags }
    if ($Step -eq 'Inspect') {
        Run-Git status --short --branch
        Run-Git remote -v
        Run-Git log -8 --oneline upstream/main
        Run-Git diff --stat custom...upstream/main
        Run-Git diff --name-only custom...upstream/main -- backend/migrations frontend/package.json frontend/pnpm-lock.yaml
        Write-Output 'Read-only inspection complete. Without -Fetch, upstream/main may be cached. Review release notes and migrations before choosing -Ref.'
        return
    }
    if ([string]::IsNullOrWhiteSpace($Ref) -or $Ref.StartsWith('-')) { throw 'Provide an explicit reviewed -Ref (tag or commit).' }
    $target = Run-Git rev-parse --verify --end-of-options "$Ref^{commit}"
    & git merge-base --is-ancestor $target upstream/main
    if ($LASTEXITCODE -ne 0) { throw 'Selected commit is not reachable from upstream/main. Review the reference; nothing was changed.' }
    if ($Step -eq 'UpdateMain') {
        & git merge-base --is-ancestor main $target
        if ($LASTEXITCODE -ne 0) { throw 'main cannot fast-forward to the selected commit. No reset or merge was performed.' }
    }
    $backup = 'backup/custom-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
    Run-Git branch $backup custom
    Write-Output "Recovery branch created: $backup"
    if ($Step -eq 'UpdateMain') {
        Run-Git switch main
        try { Run-Git merge --ff-only $target } finally { Run-Git switch custom }
        Write-Output 'Local main updated by fast-forward. Returned to custom. No merge into custom and no push.'
    } else {
        # Leave even a fast-forward candidate uncommitted so the result can be reviewed.
        & git merge --no-ff --no-commit $target
        if ($LASTEXITCODE -ne 0) {
            throw 'Merge stopped. Inspect git status and resolve conflicts on custom, or use git merge --abort. No automatic conflict resolution was attempted.'
        }
        Write-Output 'Review the merge, run Validate-Custom.ps1, and commit manually. No push or deployment was performed.'
    }
} finally {
    Pop-Location
}
