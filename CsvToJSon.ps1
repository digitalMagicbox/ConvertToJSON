# CSVファイルをJSON形式に変換する

Param(
    [string]$csvfilepath,
    [string]$jsonfilepath
)
Import-CSV $csvfilepath -Encoding Default | ConvertTo-Json | Out-File -FilePath $jsonfilepath -Encoding UTF8
