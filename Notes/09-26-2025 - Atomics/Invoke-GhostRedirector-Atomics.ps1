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
    # Ingress Tool Transfer and Web Protocols (downloads, staging)
    @{ Id = 'T1105'; Guids = @(
        'dd3b61dd-7bbc-48cd-ab51-49ad1a776df0', # certutil urlcache
        'ffd492e3-0455-4518-9fb1-46527c9f241b', # certutil verifyctl
        '42dc4460-9aa6-45d3-b1a6-3955d34e1fe8', # PS Download
        'a1921cd3-9a2d-47d5-a891-f1d0f2a7a31b', # BITSAdmin
        '2b080b99-0deb-4d51-af0f-833d37c4ca6a', # curl to ProgramData
        '6934c16e-0b3a-4e7f-ab8c-c414acd32181'  # sqlcmd download
      ) },
    @{ Id = 'T1071.001'; Numbers = @(1,2) },        # Malicious user agents (PS, CMD)

    # IIS module & webshell behavior
    @{ Id = 'T1505.004'; Numbers = @(1,2) },         # Install IIS module (appcmd, PS)
    @{ Id = 'T1505.003'; Numbers = @(1) },           # Web shell written to disk

    # Execution
    @{ Id = 'T1059.001'; Numbers = @(15) },          # PowerShell Command Execution
    @{ Id = 'T1059.003'; Numbers = @(2) },           # CMD write/display file
    @{ Id = 'T1106'; Numbers = @(1) },               # CreateProcess via Win32 API

    # Obfuscation/Decoding
    @{ Id = 'T1027'; Numbers = @(2) },               # Execute base64-encoded PowerShell
    @{ Id = 'T1140'; Numbers = @(1,2) },             # Certutil encode/decode; rename+decode

    # Privilege Escalation & Admin Creation
    @{ Id = 'T1134.001'; Numbers = @(4,5) },         # BadPotato, JuicyPotato
    @{ Id = 'T1136.001'; Numbers = @(6,8) },         # Create admin via net; via .NET

    # Remote access software (proxy for GoToHTTP)
    @{ Id = 'T1219'; Numbers = @(1,2) }              # TeamViewer, AnyDesk
)

Write-Host "PathToAtomicsFolder: $PathToAtomicsFolder" -ForegroundColor DarkGray
Write-Host ("Invoke-AtomicRedTeam module: " + ((Get-Module Invoke-AtomicRedTeam).Path)) -ForegroundColor DarkGray

foreach ($step in $chain) {
    try {
        Run-AtomicSet $step.Id -TestNumbers $step.Numbers -TestGuids $step.Guids
        Start-Sleep -Seconds 3
    } catch {
        Write-Host "Error running $($step.Id): $_" -ForegroundColor Red
    }
}

Write-Host "Done." -ForegroundColor Green