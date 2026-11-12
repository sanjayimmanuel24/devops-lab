# EXPERIMENT 4 - Jenkins deployment using Docker
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1
#   -CopyPipeline   copy the Jenkinsfile to the clipboard (to paste into the job's "Pipeline script" box)
#   -Down           stop Jenkins (keeps the jenkins_home volume, so your setup survives)

param(
    [switch]$CopyPipeline,
    [switch]$Down
)

. "$PSScriptRoot\..\scripts\common.ps1"
Set-Location $PSScriptRoot

if ($CopyPipeline) {
    Get-Content -Raw -Encoding UTF8 Jenkinsfile | Set-Clipboard
    Write-Host "Pipeline script copied to clipboard. Paste it into: New Item > karunya-site-pipeline > Pipeline > Pipeline script." -ForegroundColor Green
    Set-Location $RepoRoot
    exit 0
}

Start-Lab "exp4-jenkins"
Assert-Docker

if ($Down) {
    Step "Stop Jenkins"
    Run "docker compose down"
    Note "Warning: 'docker compose down -v' would also delete the jenkins_home volume (all Jenkins setup and jobs)."
    Set-Location $RepoRoot
    Stop-Lab
    exit 0
}

Step "docker-compose.yml"
Run "Get-Content docker-compose.yml"

Step "Start Jenkins in detached mode"
Run "docker compose up -d"
Run "docker compose ps"

Step "Wait for Jenkins and read the initial admin password"
$password = $null
for ($i = 0; $i -lt 60; $i++) {
    $password = (docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>$null)
    if ($LASTEXITCODE -eq 0 -and $password) { break }
    $password = $null
    Start-Sleep -Seconds 3
}
if ($password) {
    Run "docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
    Set-Clipboard -Value $password
    Note "Password copied to clipboard - paste it on the 'Unlock Jenkins' page."
} else {
    Note "No initialAdminPassword file: Jenkins was already set up earlier on this machine. Log in with the admin user you created."
    Note "If Jenkins is still starting, check:  docker compose logs jenkins"
}

if (Test-Url "http://localhost:8080/login" 40) { Start-Process "http://localhost:8080" }

Step "Next steps in the browser"
Note "1. Unlock Jenkins -> Install suggested plugins -> create the admin user."
Note "2. Manage Jenkins > Plugins > Available plugins > 'HTML Publisher' > Install."
Note "3. New Item > name: karunya-site-pipeline > Pipeline > OK."
Note "4. In 'Pipeline script' paste the Jenkinsfile. To copy it, run:"
Write-Host "     powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1 -CopyPipeline" -ForegroundColor Green
Note "5. Save > Build Now > open build #1 > 'Karunya University - Simple Site' and 'Build Artifacts'."

Step "Result"
Note "Thus, Jenkins was deployed using Docker Compose and a pipeline was executed to generate, publish and archive a static website."
Note "Useful: docker compose ps | docker compose logs jenkins | run.ps1 -Down"
Set-Location $RepoRoot
Stop-Lab
