# Build and serve the nBhumi web apps locally.
#
# Usage:
#   .\tool\run_web.ps1              build both apps, then serve both
#   .\tool\run_web.ps1 -Serve:$false build only
#   .\tool\run_web.ps1 -UserPort 4000 -AdminPort 4001
#
# Credentials come from .env.local (gitignored) — see Rule 7. Nothing is
# hardcoded in source; they are forwarded as --dart-define, which compiles them
# into the bundle only for this build.
#
# Endpoints:
#   User app    http://localhost:<UserPort>
#   Admin panel http://localhost:<AdminPort>   (stands in for the admin subdomain)

param(
    [int]$UserPort = 3000,
    [int]$AdminPort = 3001,
    [bool]$Serve = $true
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot '.env.local'

if (-not (Test-Path $envFile)) {
    throw "Missing $envFile. Copy .env.example to .env.local and fill in your Supabase URL and publishable key."
}

# Parse the env file into a hashtable, skipping comments and blank lines.
$config = @{}
foreach ($line in Get-Content $envFile) {
    $trimmed = $line.Trim()
    if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }
    $idx = $trimmed.IndexOf('=')
    if ($idx -lt 1) { continue }
    $config[$trimmed.Substring(0, $idx).Trim()] = $trimmed.Substring($idx + 1).Trim()
}

$supabaseUrl = $config['SUPABASE_URL']
$supabaseKey = $config['SUPABASE_PUBLISHABLE_KEY']

if ([string]::IsNullOrWhiteSpace($supabaseUrl) -or [string]::IsNullOrWhiteSpace($supabaseKey)) {
    throw "$envFile must define SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY."
}

# Shared dart-define args. The publishable key is RLS-bound and client-safe;
# a service_role key must never be passed here (Rule 2).
$environmentName = 'dev'
if ($config.ContainsKey('ENVIRONMENT')) { $environmentName = $config['ENVIRONMENT'] }

$defines = @(
    "--dart-define=SUPABASE_URL=$supabaseUrl",
    "--dart-define=SUPABASE_PUBLISHABLE_KEY=$supabaseKey",
    "--dart-define=ENVIRONMENT=$environmentName"
)

function Build-App {
    param([string]$Name, [string]$Dir, [string]$BaseHref, [string]$PwaStrategy)

    Write-Host "`n=== Building $Name (web, release) ===" -ForegroundColor Cyan
    Push-Location (Join-Path $repoRoot $Dir)
    try {
        # Native commands write non-fatal warnings to stderr. With
        # $ErrorActionPreference = 'Stop' PowerShell turns any stderr write into
        # a terminating error, which aborts the build that actually succeeded.
        # Flip to Continue and judge the build by its exit code instead.
        $previousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            flutter build web --release --base-href $BaseHref --pwa-strategy $PwaStrategy @defines 2>&1 |
                Write-Host
        } finally {
            $ErrorActionPreference = $previousPreference
        }
        if ($LASTEXITCODE -ne 0) { throw "$Name build failed (exit $LASTEXITCODE)." }

        $outFile = Join-Path (Get-Location) 'build/web/index.html'
        if (-not (Test-Path $outFile)) { throw "$Name build reported success but $outFile is missing." }
    } finally {
        Pop-Location
    }
}

Build-App -Name 'user-app'   -Dir 'apps/user_app'   -BaseHref '/' -PwaStrategy 'offline-first'
Build-App -Name 'admin-panel' -Dir 'apps/admin_panel' -BaseHref '/' -PwaStrategy 'none'

if (-not $Serve) {
    Write-Host "`nBuilds complete. Serving skipped (-Serve `$false)." -ForegroundColor Yellow
    exit 0
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "`nnpx not found. Serve manually:" -ForegroundColor Yellow
    Write-Host "  npx serve apps/user_app/build/web   -l $UserPort"
    Write-Host "  npx serve apps/admin_panel/build/web -l $AdminPort"
    exit 0
}

Write-Host "`n=== Serving ===" -ForegroundColor Cyan
Write-Host "User app     http://localhost:$UserPort" -ForegroundColor Green
Write-Host "Admin panel  http://localhost:$AdminPort" -ForegroundColor Green
Write-Host "`nPress Ctrl+C to stop both.`n"

$userJob = Start-Process -FilePath 'npx' -ArgumentList @(
    'serve', (Join-Path $repoRoot 'apps/user_app/build/web'), '-l', $UserPort, '--no-clipboard'
) -PassThru -WindowStyle Normal

$adminJob = Start-Process -FilePath 'npx' -ArgumentList @(
    'serve', (Join-Path $repoRoot 'apps/admin_panel/build/web'), '-l', $AdminPort, '--no-clipboard'
) -PassThru -WindowStyle Normal

try {
    Wait-Process -Id $userJob.Id, $adminJob.Id
} finally {
    Stop-Process -Id $userJob.Id -ErrorAction SilentlyContinue
    Stop-Process -Id $adminJob.Id -ErrorAction SilentlyContinue
}
