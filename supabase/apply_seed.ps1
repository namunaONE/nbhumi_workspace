# Apply municipalities seed in chunks
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
            $uri = "https://rerjioibpqvcomdingte.supabase.co/rest/v1/rpc/exec_sql"
            $headers = @{
                "Authorization" = "Bearer sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
                "Content-Type" = "application/json"
                "apikey" = "sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
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
    $uri = "https://rerjioibpqvcomdingte.supabase.co/rest/v1/rpc/exec_sql"
    $headers = @{
        "Authorization" = "Bearer sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
        "Content-Type" = "application/json"
        "apikey" = "sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
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