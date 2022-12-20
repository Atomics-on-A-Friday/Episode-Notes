# Atomics on a Friday - Episode X

## Overview
We are gathered here today ...

## Topics
- emulation
- why it matters
- interesting perspectives

---
## Atomics

Technique | GUID | Title
--- | --- | --- 
T1078.001 | c01cad7f-7a4c-49df-985e-b190dcf6a279 | Local Scheduled Task
T1105  | c01cad7f-7a4c-49df-985e-b190dcf6a279 | PowerShell Invoke-WebRequest
T1136.001 | 6657864e-0323-4206-9344-ac9cd7265a4f | Local Account Creation
T1078.001 | 99747561-ed8d-47f2-9c91-1e5fde1ed6e0 | Enable Local Account & Add account RDP Users Group
T1562.001 | 6b8df440-51ec-4d53-bf83-899591c9b5d7 | Disable Windows Defender
T1003.001 | 2536dee2-12fb-459a-8c37-971844fa73be | Minidump via ComSvc
T1560 | 41410c60-614d-4b9d-b66e-b0192dd9c597 | Create Archive via Compress-Archive

--- 
## Detections
### T1078.001 - Scheduled Task

Type | Data Source | Logic
--- | --- | ---
Endpoint | Event 4698 - Scheduled Task was Created | Command contains `rundll32` AND command contains `Blah`

## Mitigations
### T1078.001 - Scheduled Task
- Go do Y on Z thing

---
## References

About | Link
--- | --- 
Local Emulation Script | https://gist.github.com/MHaggis/cfa75340c485cf67cbf3b5e98c00428c