# Credentials come from the environment (Rule 7): set SUPABASE_URL and
# SUPABASE_PUBLISHABLE_KEY first, e.g. by dot-sourcing .env.local.
if (-not $env:SUPABASE_URL -or -not $env:SUPABASE_PUBLISHABLE_KEY) {
    throw 'Set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY before running this script.'
}
$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
$parts = $content -split '(?=insert into)'

$batch = @()
$batchSize = 25
$batchNum = 0

foreach ($part in $parts) {
    if ($part.Trim() -and $part.Trim().StartsWith('insert into')) {
        $batch += $part.Trim()
        if ($batch.Count -ge 25) {
            $batchNum++
            Write-Host ("Batch {0}: {1} statements" -f $batchNum, $batch.Count)
            $uri = "$env:SUPABASE_URL/rest/v1/rpc/exec_sql"
            $headers = @{
                "Authorization" = "Bearer $env:SUPABASE_PUBLISHABLE_KEY"
                "Content-Type" = "application/json"
                "apikey" = "$env:SUPABASE_PUBLISHABLE_KEY"
            }
            $body = @{ query = $batch -join "`r`n" } | ConvertTo-Json -Depth 10
            try {
                Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 60
                Write-Host ("  Applied batch {0} ({1} statements)" -f $batchNum, $batch.Count)
            } catch {
                Write-Error ("Batch {0} failed: {1}" -f $batchNum, $_)
            }
            $batch = @()
        }
    }
}

# Final batch
if ($batch.Count -gt 0) {
    Write-Host "Final batch: $($batch.Count) statements"
    $uri = "$env:SUPABASE_URL/rest/v1/rpc/exec_sql"
    $headers = @{
        "Authorization" = "Bearer $env:SUPABASE_PUBLISHABLE_KEY"
        "Content-Type" = "application/json"
        "apikey" = "$env:SUPABASE_PUBLISHABLE_KEY"
    }
    $body = @{ query = $batch -join "`r`n" } | ConvertTo-Json -Depth 10
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 60
        Write-Host "Final batch applied: $($batch.Count) statements"
    } catch {
        Write-Error "Final batch failed: $_"
    }
}

Write-Host 'Done!'