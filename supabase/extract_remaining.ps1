$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
# Skip first 75 insert statements (3 batches of 25 = 75 already done)
# Find the 76th insert statement
$idx = 0
$insertCount = 0
$targetIdx = -1
while (($idx = $content.IndexOf("insert into", $idx)) -ne -1) {
    $insertCount++
    if ($insertCount -eq 76) {
        $targetIdx = $idx
        break
    }
    $idx += 10
}
if ($targetIdx -ge 0) {
    $remaining = $content.Substring($targetIdx)
    Write-Host "Remaining length: $($remaining.Length)"
    Set-Content -Path "migrations/20261005000012_municipalities_seed_remaining.sql" -Value $remaining -Encoding UTF8
    Write-Host "Saved remaining seed to migration file"
} else {
    Write-Host "Could not find 76th insert"
}