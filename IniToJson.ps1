# INIファイルをJSON形式に変換する

Param(
    [string]$inifilepath,
    [string]$jsonfilepath
)
Out-File -FilePath $jsonfilepath -Encoding UTF8 

$enc = [Text.Encoding]::GetEncoding("Shift_JIS")

$fh = New-Object System.IO.StreamReader($inifilepath, $enc)

# セクション毎の配列を作成する
$sections = @()

while ($null -ne ($l = $fh.ReadLine())) {
    if ( [String]::IsNullOrEmpty($l) ) {
        continue
    }
    if ($l[0] -eq '[') {
        # セクションのとき
        if ($null -ne $sec) {
            $sections += $keys
        }
        $sec = $l -replace '\[|\]', ''
        $keys = @{ }
        $l = "Section=" + $sec
    }

    # エスケープ シーケンスとして扱われないように置換する。
    # ConvertFrom-StringDataで変換エラーが発生する。
    $l = $l -replace '\\', '\\'

    $keys += ConvertFrom-StringData($l)
}
$sections | ConvertTo-Json | Out-File -FilePath $jsonfilepath -Encoding UTF8 -Append
