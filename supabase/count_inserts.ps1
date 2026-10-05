$content = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
$lines = $content -split "`r`n"
$count = 0
foreach ($line in $lines) {
    if ($line.Trim().StartsWith("insert into")) {
        $count++
    }
}
Write-Host "Insert count: $count"