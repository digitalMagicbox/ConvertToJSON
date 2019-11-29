# CSVファイルをJSON形式に変換する

Param(
    [string]$csvfilepath,
    [string]$jsonfilepath
)
Out-File -FilePath $jsonfilepath -Encoding UTF8 

$list=Get-ChildItem -Path (Join-Path $csvfilepath "*.csv") -Recurse -Name
foreach ($filename in $list)
{
    Write-Host (Join-Path $csvfilepath $filename)
    Import-CSV (Join-Path $csvfilepath $filename) -Encoding Default | ConvertTo-Json | Out-File -FilePath $jsonfilepath -Encoding UTF8
}
