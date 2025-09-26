param(
    [string]$PathToAtomicsFolder = (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'atomics'),
    [switch]$GetPrereqsOnly,
    [switch]$VerboseOutput
)


if (-not $PSBoundParameters.ContainsKey('PathToAtomicsFolder')) {
    if (Test-Path 'C:\AtomicRedTeam\atomics') {
        $PathToAtomicsFolder = 'C:\AtomicRedTeam\atomics'
    }
}
elseif (-not (Test-Path $PathToAtomicsFolder) -and (Test-Path 'C:\AtomicRedTeam\atomics')) {
    $PathToAtomicsFolder = 'C:\AtomicRedTeam\atomics'
}

function Ensure-InvokeAtomicRedTeamModule {
    $candidate = Join-Path (Split-Path -Parent $PathToAtomicsFolder) 'invoke-atomicredteam\Invoke-AtomicRedTeam.psd1'
    if (Test-Path $candidate) {
        Import-Module $candidate -ErrorAction Stop
        return
    }

    if (-not (Get-Module -ListAvailable -Name Invoke-AtomicRedTeam)) {
        try {
            Install-Module -Name Invoke-AtomicRedTeam -Scope CurrentUser -Force -ErrorAction Stop
        } catch {
            Write-Host "Failed to install Invoke-AtomicRedTeam: $_" -ForegroundColor Red
            throw
        }
    }
    Import-Module Invoke-AtomicRedTeam -ErrorAction Stop
}

function Run-AtomicSet {
    param(
        [Parameter(Mandatory=$true)][string]$TechniqueId,
        [int[]]$TestNumbers,
        [string[]]$TestGuids
    )

    Write-Host "==> Technique $TechniqueId" -ForegroundColor Cyan

    if ($TestNumbers -and $TestNumbers.Count -gt 0) {
        if ($GetPrereqsOnly) {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -GetPrereqs -TestNumbers $TestNumbers -ErrorAction Continue | Out-Null
            return
        }
        Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -CheckPrereqs -TestNumbers $TestNumbers -ErrorAction Continue | Out-Null
        if ($VerboseOutput) {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -TestNumbers $TestNumbers -Confirm:$false -ErrorAction Continue -Verbose
        } else {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -TestNumbers $TestNumbers -Confirm:$false -ErrorAction Continue
        }
    }

    if ($TestGuids -and $TestGuids.Count -gt 0) {
        if ($GetPrereqsOnly) {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -GetPrereqs -TestGuids $TestGuids -ErrorAction Continue | Out-Null
            return
        }
        Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -CheckPrereqs -TestGuids $TestGuids -ErrorAction Continue | Out-Null
        if ($VerboseOutput) {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -TestGuids $TestGuids -Confirm:$false -ErrorAction Continue -Verbose
        } else {
            Invoke-AtomicTest $TechniqueId -PathToAtomicsFolder $PathToAtomicsFolder -TestGuids $TestGuids -Confirm:$false -ErrorAction Continue
        }
    }
}

Write-Host "Preparing Atomic Red Team environment..." -ForegroundColor Yellow
Ensure-InvokeAtomicRedTeamModule

$chain = @(
    # Delivery: CHM
    @{ Id = 'T1218.001'; Numbers = @(1,8) },            # hh.exe local payload, decompile local CHM
    # Execution: MSHTA
    @{ Id = 'T1218.005'; Numbers = @(1,3,10) },          # mshta JS scheme, remote HTA, mshta executes PowerShell
    # Persistence: Scheduled Task, Registry Run
    @{ Id = 'T1053.005'; Numbers = @(1,2,7) },           # create/run tasks; base64 cmd from registry via task
    @{ Id = 'T1547.001'; Numbers = @(1,3,7) },           # Run key; PS RunOnce; Startup .lnk
    # Shortcut modification to simulate LNK behaviors
    @{ Id = 'T1547.009'; Numbers = @(1) },               # Shortcut Modification
    # Scripting Interpreters (safe examples)
    @{ Id = 'T1059.003'; Numbers = @(1) },               # CMD
    @{ Id = 'T1059.007'; Numbers = @(1) },               # JScript via cscript
    # Archive + Exfil + Encoding + C2
    @{ Id = 'T1560.001'; Numbers = @(1,2) },             # RAR compress, RAR with password
    @{ Id = 'T1041'; Numbers = @(1) },                    # Exfil over C2 (HTTP POST)
    @{ Id = 'T1132.001'; Numbers = @(1) },               # Base64 encoded data
    @{ Id = 'T1071.001'; Numbers = @(1,2) },             # Web protocols (PowerShell, curl)
    # Evidence cleanup (file deletion)
    @{ Id = 'T1070.004'; Numbers = @(1) },               # Delete files quietly
    # File Ops: Expand CAB, curl to ProgramData (precise via GUIDs)
    @{ Id = 'T1140'; Guids = @('9f8b1c54-cb76-4d5e-bb1f-2f5c0e8f5a11') }, # Expand CAB with expand.exe
    @{ Id = 'T1105'; Guids = @('2b080b99-0deb-4d51-af0f-833d37c4ca6a') }  # Curl Download File
)

Write-Host "PathToAtomicsFolder: $PathToAtomicsFolder" -ForegroundColor DarkGray
$modPaths = Get-Module Invoke-AtomicRedTeam | Select-Object -ExpandProperty Path
if ($modPaths) {
    Write-Host ("Invoke-AtomicRedTeam module: " + ($modPaths -join ' | ')) -ForegroundColor DarkGray
}

foreach ($step in $chain) {
    try {
        Run-AtomicSet $step.Id -TestNumbers $step.Numbers -TestGuids $step.Guids
        Start-Sleep -Seconds 3
    } catch {
        Write-Host "Error running $($step.Id): $_" -ForegroundColor Red
    }
}

Write-Host "Done." -ForegroundColor Green


