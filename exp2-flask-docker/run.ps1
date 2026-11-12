# EXPERIMENT 2 - Flask application containerization and Docker Hub deployment
# Run from the repo root:
#   powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1            build + run locally
#   powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1 -Push      ...and push to Docker Hub
#   powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1 -PullOnly  "another machine": pull from Docker Hub and run

param(
    [switch]$Push,
    [switch]$PullOnly,
    [int]$HostPort = 5050,
    [switch]$Pause
)

. "$PSScriptRoot\..\scripts\common.ps1"
Start-Lab "exp2-flask-docker"
Assert-Docker
Set-Location $PSScriptRoot

$local  = "flask-docker-app"
$remote = "$DockerHubUser/flask-docker-app:latest"
$url    = "http://localhost:$HostPort"

Step "Folder structure"
Run "Get-ChildItem -Name"
Run "Get-Content Dockerfile"

if ($PullOnly) {
    Assert-Configured $DockerHubUser "DockerHubUser"
    Step "Pull and run on another machine"
    Run "docker pull $remote"
    $image = $remote
} else {
    Step "Build the image"
    Run "docker build -t $local ."
    Run "docker images $local"
    $image = $local
}
if ($Pause) { Wait-Enter }

Step "Run the container (host port $HostPort -> container port 5000)"
docker rm -f flask-app *> $null
Run "docker run -d --name flask-app -p ${HostPort}:5000 $image"
Note "(the manual runs it in the foreground: docker run -p ${HostPort}:5000 $image - -d just keeps this window free)"
Run "docker ps"
if (Test-Url $url) { Start-Process $url }
Run "docker logs flask-app"
if ($Pause) { Wait-Enter }

if ($Push -and -not $PullOnly) {
    Assert-Configured $DockerHubUser "DockerHubUser"
    Step "Login, tag and push to Docker Hub"
    Note "Use a Docker Hub access token as the password (hub.docker.com > Account settings > Personal access tokens)."
    RunLive "docker login -u $DockerHubUser"
    Run "docker tag $local $remote"
    Run "docker images"
    Run "docker push $remote"
    Note "Check it at: https://hub.docker.com/r/$DockerHubUser/flask-docker-app"
}

Step "Result"
Note "Thus, the Flask web application was successfully containerized, executed as a Docker container and uploaded to Docker Hub."
Note "Stop it later with:  docker rm -f flask-app"
Set-Location $RepoRoot
Stop-Lab
