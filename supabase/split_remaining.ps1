$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\migrations\20261005000012_municipalities_seed_remaining.sql" -Raw -Encoding UTF8
$statements = $content -split '(?=insert into)' | Where-Object { $_.Trim().StartsWith('insert into') }
$count = $statements.Count
Write-Host "Total statements: $count"

$chunkSize = [Math]::Ceiling($count / 3)
Write-Host "Chunk size: $chunkSize"

for ($i = 0; $i -lt 3; $i++) {
    $start = $i * $chunkSize
    $end = [Math]::Min(($i + 1) * $chunkSize, $count)
    $chunk = $statements[$start..($end - 1)] -join "`r`n"
    $file = "migrations/20261005000012_municipalities_seed_chunk$($i + 1).sql"
    Set-Content -Path $file -Value ($chunk + "`r`n") -Encoding UTF8
    Write-Host "Created $file with $(($end - $start)) statements"
}