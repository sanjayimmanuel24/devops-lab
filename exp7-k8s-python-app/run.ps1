# EXPERIMENT 7 - Kubernetes Deployment and Service for a Python app from Docker Hub
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File .\exp7-k8s-python-app\run.ps1
#   -Image other/image:tag   use a different image (must listen on port 5000)
#   -Cleanup                 delete the Deployment + Service
#   -StopCluster             with -Cleanup: also "minikube stop"
# Default image: <DockerHubUser>/flask-docker-app:latest - push it first with exp2-flask-docker\run.ps1 -Push

param(
    [string]$Image = "",
    [switch]$Cleanup,
    [switch]$StopCluster
)

. "$PSScriptRoot\..\scripts\common.ps1"
Set-Location $PSScriptRoot
Start-Lab "exp7-k8s-python-app"
Assert-Docker
Assert-Tool "kubectl" "Install kubectl."
Assert-Tool "minikube" "Install Minikube."

if ($Cleanup) {
    Step "Cleanup"
    Run "kubectl delete -f python-service.yaml --ignore-not-found"
    Run "kubectl delete -f python-deployment.yaml --ignore-not-found"
    if ($StopCluster) { Run "minikube stop" }
    Set-Location $RepoRoot; Stop-Lab; exit 0
}

if (-not $Image) {
    Assert-Configured $DockerHubUser "DockerHubUser"
    $Image = "$DockerHubUser/flask-docker-app:latest"
}

Step "1. Start and verify the cluster"
minikube status *> $null
if ($LASTEXITCODE -ne 0) { Run "minikube start --driver=docker" } else { Note "(minikube is already running)" }
Run "kubectl get nodes"

Step "2. Check the image can be pulled from Docker Hub"
Run "docker pull $Image"
if ($Rc -ne 0) {
    Write-Host "Cannot pull $Image. Push it first:  .\exp2-flask-docker\run.ps1 -Push   (or pass -Image)" -ForegroundColor Red
    Set-Location $RepoRoot; Stop-Lab; exit 1
}

Step "3. Apply the Deployment (2 replicas)"
$rendered = Join-Path $env:TEMP "python-deployment.rendered.yaml"
(Get-Content python-deployment.yaml) -replace 'YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest', $Image | Set-Content -Encoding ascii $rendered
Run "Get-Content python-deployment.yaml"
Note "(image used: $Image)"
Run "kubectl apply -f `"$rendered`""
Run "kubectl rollout status deployment/python-web-deployment --timeout=180s"
Run "kubectl get deployments"
Run "kubectl get pods -l app=python-web -o wide"
Run "kubectl describe deployment python-web-deployment"

Step "4. Apply the NodePort Service"
Run "Get-Content python-service.yaml"
Run "kubectl apply -f python-service.yaml"
Run "kubectl get svc"

Step "5. Open the app"
Note "minikube prints the URL in the new window and opens a tunnel - keep that window open while you show the page."
RunInNewWindow "minikube service python-web-service --url"

Step "Result"
Note "Thus, the Python web application image was deployed to Kubernetes using a Deployment with two replicas, exposed through a NodePort Service and accessed using Minikube."
Note "Clean up afterwards with:  powershell -ExecutionPolicy Bypass -File .\exp7-k8s-python-app\run.ps1 -Cleanup -StopCluster"
Set-Location $RepoRoot
Stop-Lab
