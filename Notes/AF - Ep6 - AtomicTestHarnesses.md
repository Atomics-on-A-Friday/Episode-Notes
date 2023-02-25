# AF - Ep 6

# Topic
On this Atomics on a Friday, Haag is joined by [Justin Elze](https://twitter.com/HackingLZ) to hang out and chat about the hot topics of technique variations, offensive tradecraft and send AtomicTestHarnesses down range! 

Watch here on YouTube to catch up!
- [Live](https://youtube.com/live/biYH6DxluTc?feature=share)
- [New-ATHService Demo](https://youtu.be/nxK7_LxcWjw)
- [Invoke-MSIexec Demo](https://youtu.be/ILeURN5RDoU)
# References

- [https://github.com/redcanaryco/AtomicTestHarnesses](https://github.com/redcanaryco/AtomicTestHarnesses)
- [https://redcanary.com/blog/introducing-atomictestharnesses](https://redcanary.com/blog/introducing-atomictestharnesses)
- [https://attack.mitre.org/techniques/T1218/007/](https://attack.mitre.org/techniques/T1218/007/)
- [https://lolbas-project.github.io/lolbas/Binaries/Msiexec/](https://lolbas-project.github.io/lolbas/Binaries/Msiexec/)
- [https://atomicredteam.io/defense-evasion/T1218.007/](https://atomicredteam.io/defense-evasion/T1218.007/)
- [Security Content MSIexec](https://research.splunk.com/stories/windows_system_binary_proxy_execution_msiexec/)
- [ATH - Service Install](https://github.com/redcanaryco/AtomicTestHarnesses/blob/master/Windows/TestHarnesses/T1543.003_WindowsService/ServiceInstaller.ps1)
- [ATH - MSIexec](https://github.com/redcanaryco/AtomicTestHarnesses/tree/master/Windows/TestHarnesses/T1218.007_Msiexec)
- [Security Content Windows Drivers](https://research.splunk.com/stories/windows_drivers/)
# Infrastructure needed

A lab

# Mitigations

Detection:
- 4104 - Script Block Logging
- 4688 / Sysmon / EDR
- 7045 / 4697 New Service installed
- Track modloads (msi.dll, jscript, vbscript, amsi)

Prevention
- WDAC + MSI
- WDAC + Driver blocklist
- HVCI
- ASR
- Any AppControl


# Demo

Commands ran during the demo:

First time running ATH?
Install with - 
```
[Net.ServicePointManager]::SecurityProtocol = 
            [Net.SecurityProtocolType]::Tls12
Install-Module -Name AtomicTestHarnesses -Scope CurrentUser
```
First time running Atomic Red Team?
```
Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
```

Install a new service

```
New-ATHService -ServiceName phymem -DisplayName 'Does driver stuff' -ServiceType KernelDriver -FilePath C:\users\administrator\desktop\mimidrv.sys -StartService
```

```
New-ATHService -ServiceName TestService -DisplayName TestService -FilePath filename.exe -Variant sc.exe -StartType AutoStart -ServiceType Win32OwnProcess -StartService
```

```
New-ATHService -ServiceName TestService -DisplayName TestService -FilePath filename.exe -Variant WMI -StartType AutoStart -ServiceType Win32OwnProcess -StartService
```
```
New-ATHService -ServiceName TestService -DisplayName TestService -FilePath C:\users\administrator\desktop\mimidrv.sys -Variant WMI -StartType AutoStart -ServiceType Win32OwnProcess -StartService
```
```
New-ATHService -ServiceName GOHOMEnothere -DisplayName NOTAPTsorry -FilePath C:\users\administrator\desktop\mimidrv.sys -Variant WMI -StartType AutoStart -ServiceType Win32OwnProcess -StartService
```