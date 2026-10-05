$c = Get-Content "C:\Users\user\StudioProjects\nbhumi_workspace\supabase\seeds\009_municipalities.sql" -Raw -Encoding UTF8
$idx = $c.IndexOf("insert into")
Write-Host "First insert at: $idx"
if ($idx -ge 0) {
    Write-Host $c.Substring($idx, 200)
}