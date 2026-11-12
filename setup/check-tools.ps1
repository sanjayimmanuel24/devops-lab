# Shows which tools are installed and whether Docker is running.
# Run:  powershell -ExecutionPolicy Bypass -File .\setup\check-tools.ps1

$checks = @(
    @{ Name = "git";            Cmd = { git --version } },
    @{ Name = "python";         Cmd = { python --version } },
    @{ Name = "docker";         Cmd = { docker --version } },
    @{ Name = "docker compose"; Cmd = { docker compose version } },
    @{ Name = "kubectl";        Cmd = { kubectl version --client } },
    @{ Name = "minikube";       Cmd = { minikube version --short } }
)

foreach ($c in $checks) {
    $exe = $c.Name.Split(" ")[0]
    if (Get-Command $exe -ErrorAction SilentlyContinue) {
        $out = (& $c.Cmd 2>&1 | Select-Object -First 1) -join ""
        Write-Host ("[ok]      {0,-15} {1}" -f $c.Name, $out) -ForegroundColor Green
    } else {
        Write-Host ("[missing] {0,-15} -> run .\setup\install-tools.ps1" -f $c.Name) -ForegroundColor Red
    }
}

if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker info *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "[ok]      Docker engine is running" -ForegroundColor Green }
    else { Write-Host "[stopped] Docker engine is NOT running -> start Docker Desktop" -ForegroundColor Red }
}

. (Join-Path (Split-Path $PSScriptRoot -Parent) "config.ps1")
if ($DockerHubUser -like "YOUR_*" -or $GitHubUser -like "YOUR_*") {
    Write-Host "[todo]    Fill in your usernames in config.ps1" -ForegroundColor Yellow
}
