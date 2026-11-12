# Shared helpers for the run.ps1 scripts. Dot-source it:  . "$PSScriptRoot\..\scripts\common.ps1"
# Every command is printed in cyan before it runs, so the examiner can see exactly what was typed.
# All output is also saved to results\<experiment>_<time>.txt

$ErrorActionPreference = 'Continue'
$RepoRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $RepoRoot "config.ps1")

function Start-Lab([string]$Name) {
    $dir = Join-Path $RepoRoot "results"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $file = Join-Path $dir ("{0}_{1}.txt" -f $Name, (Get-Date -Format "yyyyMMdd-HHmmss"))
    try { Start-Transcript -Path $file | Out-Null; $Global:LabTranscript = $file } catch { $Global:LabTranscript = $null }
    Write-Host ("Output is being saved to " + $file) -ForegroundColor DarkGray
}

function Stop-Lab {
    if ($Global:LabTranscript) {
        try { Stop-Transcript | Out-Null } catch {}
        Write-Host ""
        Write-Host ("Saved output: " + $Global:LabTranscript) -ForegroundColor Green
    }
}

function Step([string]$Title) {
    Write-Host ""
    Write-Host ("=== " + $Title + " ===") -ForegroundColor Yellow
}

function Note([string]$Text) { Write-Host $Text -ForegroundColor Gray }

# Print a command, run it, show stdout+stderr as plain text. Returns nothing; exit code in $Global:Rc.
function Run([string]$Command) {
    Write-Host ("PS> " + $Command) -ForegroundColor Cyan
    $Global:LASTEXITCODE = 0
    Invoke-Expression ($Command + " 2>&1") | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            # stderr lines from native tools (git/docker/kubectl print progress there) - show as plain text
            $m = $_.Exception.Message
            if ($m -eq "System.Management.Automation.RemoteException") { "" } else { $m }
        } else { "$_" }
    } | Out-Host
    $Global:Rc = $LASTEXITCODE
}

# Same as Run, but output is not piped. Use for commands that prompt (docker login).
function RunLive([string]$Command) {
    Write-Host ("PS> " + $Command) -ForegroundColor Cyan
    $Global:LASTEXITCODE = 0
    Invoke-Expression $Command
    $Global:Rc = $LASTEXITCODE
}

# Open a command in its own PowerShell window (for commands that never exit: port-forward, minikube service).
function RunInNewWindow([string]$Command, [string]$WorkDir = (Get-Location).Path) {
    Write-Host ("PS> " + $Command + "    (in a new window - keep it open)") -ForegroundColor Cyan
    Start-Process powershell -WorkingDirectory $WorkDir -ArgumentList @("-NoExit", "-Command", $Command) | Out-Null
}

function Wait-Enter([string]$Message = "Press Enter to continue") {
    Read-Host ("  >> " + $Message) | Out-Null
}

function Assert-Tool([string]$Name, [string]$Hint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host ("'" + $Name + "' is not installed / not on PATH. " + $Hint) -ForegroundColor Red
        Write-Host "Run:  .\setup\install-tools.ps1   (then open a NEW terminal)" -ForegroundColor Red
        Stop-Lab
        exit 1
    }
}

function Assert-Docker {
    Assert-Tool "docker" "Install Docker Desktop."
    docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker is installed but not running. Start Docker Desktop, wait until it says 'Engine running', then re-run." -ForegroundColor Red
        Stop-Lab
        exit 1
    }
}

function Assert-Configured([string]$Value, [string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value -like "YOUR_*") {
        Write-Host ("Set " + $Name + " in config.ps1 first.") -ForegroundColor Red
        Stop-Lab
        exit 1
    }
}

function Test-Url([string]$Url, [int]$Tries = 15) {
    for ($i = 0; $i -lt $Tries; $i++) {
        try {
            $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
            Write-Host ("GET " + $Url + " -> HTTP " + $r.StatusCode) -ForegroundColor Green
            return $true
        } catch { Start-Sleep -Seconds 2 }
    }
    Write-Host ("Could not reach " + $Url) -ForegroundColor Red
    return $false
}
