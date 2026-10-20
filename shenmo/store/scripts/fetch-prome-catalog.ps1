param([string]$OutputPath = (Join-Path $PSScriptRoot '..\work\prome-catalog.json'))
$ErrorActionPreference = 'Stop'
$catalogRoot = 'https://prome666.com'
$categoryResponse = (Invoke-WebRequest ($catalogRoot + '/user/api/index/data') -TimeoutSec 20).Content | ConvertFrom-Json
if ($categoryResponse.code -ne 200) { throw 'The category endpoint returned an error.' }
$categories = @($categoryResponse.data | Where-Object { $_.status -eq 1 -and -not $_.hide })
if ($categories.Count -eq 0 -or $categories.Count -gt 50) { throw 'Unexpected category list. No output was written.' }
$items = [System.Collections.Generic.List[object]]::new()
foreach ($category in $categories) {
    $categoryId = [string]$category.id
    if ($categoryId -notmatch '^\d+$') { throw 'Invalid category ID.' }
    for ($page = 1; $page -le 20; $page++) {
        $response = (Invoke-WebRequest ($catalogRoot + '/user/api/index/commodity?categoryId=' + $categoryId + '&limit=100&page=' + $page) -TimeoutSec 20).Content | ConvertFrom-Json
        if ($response.code -ne 200) { throw 'The product endpoint returned an error. Existing output was not changed.' }
        foreach ($item in $response.data) { $items.Add($item) }
        if ($items.Count -gt 2000) { throw 'Snapshot exceeds the supported size.' }
        if ($response.data.Count -eq 0 -or $page * 100 -ge $response.total) { break }
        if ($page -eq 20) { throw 'Pagination limit reached. Existing output was not changed.' }
    }
}
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($resolvedOutput)) | Out-Null
$snapshot = @{ categories = $categories; products = @($items.ToArray()); captured_at = [DateTime]::UtcNow.ToString('o'); source = $catalogRoot }
$snapshot | ConvertTo-Json -Depth 15 -Compress | Set-Content -LiteralPath $resolvedOutput -Encoding utf8
Write-Output ('Saved ' + $items.Count + ' category listing rows to ' + $resolvedOutput)
Write-Output 'Import this JSON through Management > Supplier products > Import catalog file.'
