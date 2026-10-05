$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
$lines = $content -split "`r`n"
$inserts = $lines | Where-Object { $_.Trim().StartsWith('insert into') }

$batchSize = 50
$batchNum = 0
$batch = @()

foreach ($line in $inserts) {
    $batch += $line
    if ($batch.Count -ge 50) {
        $batchNum++
        $batchSql = $batch -join "`r`n"
        $file = "migrations/20261005000012_municipalities_seed_batch$batchNum.sql"
        Set-Content -Path $file -Value $batchSql -Encoding UTF8
        Write-Host ("Created {0} with {1} statements" -f $file, $batch.Count)
        $batch = @()
    }
}

if ($batch.Count -gt 0) {
    $batchNum++
    $batchSql = $batch -join "`r`n"
    $file = "migrations/20261005000012_municipalities_seed_batch$batchNum.sql"
    Set-Content -Path $file -Value $batchSql -Encoding UTF8
    Write-Host ("Created {0} with {1} statements" -f $file, $batch.Count)
}

Write-Host ("Done creating {0} batch files" -f $batchNum)