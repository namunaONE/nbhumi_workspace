# Apply municipalities seed in chunks.
# Credentials come from the environment (Rule 7): set SUPABASE_URL and
# SUPABASE_PUBLISHABLE_KEY first, e.g. by dot-sourcing .env.local.
if (-not $env:SUPABASE_URL -or -not $env:SUPABASE_PUBLISHABLE_KEY) {
    throw 'Set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY before running this script.'
}
$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
$statements = $content -split '(?<=;\r\n)(?=insert into)' -ne ''

$count = 0
$batch = @()
$batchSize = 20

foreach ($stmt in $statements) {
    if ($stmt.Trim()) {
        $batch += $stmt.Trim()
        if ($batch.Count -ge $batchSize) {
            $batchSql = $batch -join "`r`n"
            $count += $batch.Count
            Write-Host "Applying batch $($count / $batchSize) with $($batch.Count) statements..."
            # Execute via Supabase REST API
            $uri = "$env:SUPABASE_URL/rest/v1/rpc/exec_sql"
            $headers = @{
                "Authorization" = "Bearer $env:SUPABASE_PUBLISHABLE_KEY"
                "Content-Type" = "application/json"
                "apikey" = "$env:SUPABASE_PUBLISHABLE_KEY"
            }
            $body = @{ query = $batchSql } | ConvertTo-Json -Depth 10
            try {
                Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 60
                Write-Host "Batch applied: $($batch.Count) statements (total: $count)"
            } catch {
                Write-Error "Failed: $_"
            }
            $batch = @()
        }
    }
}

# Remaining
if ($batch.Count -gt 0) {
    $batchSql = $batch -join "`r`n"
    $count += $batch.Count
    Write-Host "Applying final batch with $($batch.Count) statements..."
    $uri = "$env:SUPABASE_URL/rest/v1/rpc/exec_sql"
    $headers = @{
        "Authorization" = "Bearer $env:SUPABASE_PUBLISHABLE_KEY"
        "Content-Type" = "application/json"
        "apikey" = "$env:SUPABASE_PUBLISHABLE_KEY"
    }
    $body = @{ query = $batch -join "`r`n" } | ConvertTo-Json -Depth 10
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 60
        Write-Host "Final batch applied: $($batch.Count) statements (total: $count)"
    } catch {
        Write-Error "Failed: $_"
    }
}

Write-Host "Done! Total statements: $count"