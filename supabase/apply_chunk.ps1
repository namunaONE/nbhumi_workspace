# Credentials come from the environment (Rule 7): set SUPABASE_URL and
# SUPABASE_PUBLISHABLE_KEY first, e.g. by dot-sourcing .env.local.
if (-not $env:SUPABASE_URL -or -not $env:SUPABASE_PUBLISHABLE_KEY) {
    throw 'Set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY before running this script.'
}
$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\migrations\20261005000012_municipalities_seed_chunk1.sql" -Raw -Encoding UTF8
$statements = $content -split '(?=insert into)' | Where-Object { $_.Trim().StartsWith('insert into') }
$count = $statements.Count
Write-Host "Total statements: $count"

$batchSize = 50
$batchNum = 0

for ($i = 0; $i -lt $count; $i += 50) {
    $batch = $statements[$i..([Math]::Min($i + 49, $statements.Count - 1))]
    $batchNum++
    $batchSql = $batch -join "`r`n" + "`r`n"
    Write-Host "Applying batch $batchNum ($($batch.Count) statements)..."
    $uri = "$env:SUPABASE_URL/rest/v1/rpc/exec_sql"
    $headers = @{
        "Authorization" = "Bearer $env:SUPABASE_PUBLISHABLE_KEY"
        "Content-Type" = "application/json"
        "apikey" = "$env:SUPABASE_PUBLISHABLE_KEY"
    }
    $body = @{ query = $batch -join "`r`n" } | ConvertTo-Json -Depth 10
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 60
        Write-Host "Batch $batchNum applied ($($batch.Count) statements)"
    } catch {
        Write-Error "Batch $batchNum failed: $_"
        break
    }
}
Write-Host "Done!"