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
            $uri = "https://rerjioibpqvcomdingte.supabase.co/rest/v1/rpc/exec_sql"
            $headers = @{
                "Authorization" = "Bearer sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
                "Content-Type" = "application/json"
                "apikey" = "sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
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
    $uri = "https://rerjioibpqvcomdingte.supabase.co/rest/v1/rpc/exec_sql"
    $headers = @{
        "Authorization" = "Bearer sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
        "Content-Type" = "application/json"
        "apikey" = "sb_publishable_DaQ2qWXImnMaQ_TV8Zedvg_xcGvy_v3"
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