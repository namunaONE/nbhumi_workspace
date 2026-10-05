$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\migrations\20261005000012_municipalities_seed_chunk2.sql" -Raw -Encoding UTF8
$statements = $content -split '(?=insert into)' | Where-Object { $_.Trim().StartsWith('insert into') }
$count = $statements.Count
Write-Host "Total statements: $count"

$chunkSize = [Math]::Ceiling($count / 5)
for ($i = 0; $i -lt 5; $i++) {
    $start = $i * [Math]::Ceiling($count / 5)
    $end = [Math]::Min(($i + 1) * [Math]::Ceiling($count / 5), $count)
    $chunk = $statements[$start..($end - 1)] -join "`r`n"
    $file = "migrations/20261005000012_municipalities_seed_chunk2_part$($i + 1).sql"
    Set-Content -Path $file -Value ($chunk + "`r`n") -Encoding UTF8
    Write-Host "Created $file with $(($end - $start)) statements"
}