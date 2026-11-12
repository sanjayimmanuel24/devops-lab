# Installs the tools the experiments need, using winget (built into Windows 10/11).
# Run in PowerShell:  powershell -ExecutionPolicy Bypass -File .\setup\install-tools.ps1
# Docker Desktop needs admin rights and WSL2; restart the PC if the installer asks.
# After installing, open a NEW terminal so PATH is refreshed, then run .\setup\check-tools.ps1

$tools = @(
    @{ Cmd = "git";      Id = "Git.Git" },
    @{ Cmd = "python";   Id = "Python.Python.3.11" },
    @{ Cmd = "docker";   Id = "Docker.DockerDesktop" },
    @{ Cmd = "kubectl";  Id = "Kubernetes.kubectl" },
    @{ Cmd = "minikube"; Id = "Kubernetes.minikube" }
)

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, or install the tools manually." -ForegroundColor Red
    exit 1
}

foreach ($t in $tools) {
    if (Get-Command $t.Cmd -ErrorAction SilentlyContinue) {
        Write-Host ("[ok]      " + $t.Cmd + " already installed") -ForegroundColor Green
    } else {
        Write-Host ("[install] " + $t.Cmd + "  (winget id " + $t.Id + ")") -ForegroundColor Yellow
        winget install --id $t.Id -e --accept-source-agreements --accept-package-agreements
    }
}

Write-Host ""
Write-Host "Done. Open a NEW terminal, start Docker Desktop, then run .\setup\check-tools.ps1" -ForegroundColor Cyan
