# Registry File to JSON file conversion

Param(
    [string]$registryfilepath,
    [string]$jsonfilepath
)

# Create Array
$replacerootkeys = @{
    'HKLM' = 'HKEY_LOCAL_MACHINE';
    'HKCU' = 'HKEY_CURRENT_USER';
    'HKCR' = 'HKEY_CLASSES_ROOT';
    'HKU'  = 'HKEY_USERS';
    'HKCC' = 'HKEY_CURRENT_CONFIG';
}

$registries = @()

Out-File -FilePath $jsonfilepath -Encoding UTF8 

$enc = [Text.Encoding]::GetEncoding('UTF-8')
$fh = New-Object System.IO.StreamReader($registryfilepath, $enc)
$l = $fh.ReadLine()
if ($l -ne 'Windows Registry Editor Version 5.00') {
    return
}
while ($null -ne ($l = $fh.ReadLine())) {
    if ( [String]::IsNullOrEmpty($l) ) {
        continue
    }
    if ($l[0] -eq '[') {
        # Subkey Section
        if ($null -ne $reg) {
            $registries += $reg
        }
        $reg = @{ }
        $subkey = $l -replace '\[|\]', ''
        $subkey_orign_length = $subkey.Length
        foreach ($rootkey in $replacerootkeys.GetEnumerator()) {
            $subkey = $subkey -replace $rootkey.Value, $rootkey.Key
            if ($subkey.Length -ne $subkey_orign_length) {
                $reg = @{ 'Subkey' = $subkey; }
                break
            }
        }
    }
    else {
        # Value Section
        $obj = $l -match '^\"(?<Name>.*)\"=(?<Type>(\"|dword:))(?<Value>.*)$' | 
        ForEach-Object { New-Object PSObject -Property $Matches } | 
        Select-Object -Property Name, Type, Value
        if ($obj.type -eq 'dword:') {
            $obj.type = 'dword'
            # Hexadecimal to decimal conversion
            $obj.value = [Convert]::ToInt32($obj.value, 16)
            $reg | Add-Member -MemberType NoteProperty -Name $obj.Name -Value $obj.value
        }
        elseif ($obj.type -eq '"') {
            $obj.type = 'string'
            if ( ![String]::IsNullOrEmpty($obj.value) ) {
                $obj.value = $obj.value.SubString(0, $obj.value.Length - 1)
            }
            $reg | Add-Member -MemberType NoteProperty -Name $obj.Name -Value $obj.value
        }
    }
}
$registries | ConvertTo-Json | Out-File -FilePath $jsonfilepath -Encoding UTF8 -Append
