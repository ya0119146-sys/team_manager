$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$count = 0
Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path)
    if ($content -match '\.withOpacity\(') {
        $newContent = [regex]::Replace($content, '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)')
        [System.IO.File]::WriteAllText($path, $newContent, $utf8NoBom)
        Write-Output "Updated: $($_.Name)"
        $count++
    }
}
Write-Output "Total files updated: $count"
