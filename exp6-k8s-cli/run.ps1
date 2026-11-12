# EXPERIMENT 6 - Manage Kubernetes resources using the CLI (Minikube + kubectl)
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File .\exp6-k8s-cli\run.ps1
#   -ShowRollback   also demonstrate "kubectl rollout undo"
#   -Cleanup        delete the Service + Deployment (and Pod) only
#   -StopCluster    with -Cleanup: also run "minikube stop"
# Commands that never exit (port-forward, minikube service --url) open in their own window.

param(
    [switch]$ShowRollback,
    [switch]$Cleanup,
    [switch]$StopCluster
)

. "$PSScriptRoot\..\scripts\common.ps1"
Set-Location $PSScriptRoot
Start-Lab "exp6-k8s-cli"
Assert-Docker
Assert-Tool "kubectl" "Install kubectl."
Assert-Tool "minikube" "Install Minikube."

if ($Cleanup) {
    Step "Cleanup"
    Run "kubectl delete svc my-nginx --ignore-not-found"
    Run "kubectl delete deployment my-nginx --ignore-not-found"
    Run "kubectl delete pod nginx-pod --ignore-not-found"
    if ($StopCluster) { Run "minikube stop" }
    Set-Location $RepoRoot; Stop-Lab; exit 0
}

Step "1. Verify tools and start the cluster"
Run "docker --version"
Run "kubectl version --client"
minikube status *> $null
if ($LASTEXITCODE -ne 0) { Run "minikube start --driver=docker" } else { Note "(minikube is already running)" }
Run "minikube status"
Run "kubectl get nodes"

Step "2. Create and inspect a Pod"
Run "Get-Content nginx-pod.yaml"
Run "kubectl apply -f nginx-pod.yaml"
Run "kubectl wait --for=condition=Ready pod/nginx-pod --timeout=180s"
Run "kubectl get pods"
Run "kubectl describe pod nginx-pod"

Step "3. Port-forward localhost:8080 -> Pod port 80"
RunInNewWindow "kubectl port-forward pod/nginx-pod 8080:80"
if (Test-Url "http://localhost:8080") { Start-Process "http://localhost:8080" }
Wait-Enter "Show the nginx welcome page, then press Enter to delete the Pod"
Run "kubectl delete pod nginx-pod"
Note "(you can close the port-forward window now)"

Step "4. Create a Deployment"
kubectl delete svc my-nginx --ignore-not-found *> $null
kubectl delete deployment my-nginx --ignore-not-found *> $null
Run "kubectl create deployment my-nginx --image=nginx"
Run "kubectl rollout status deployment/my-nginx --timeout=180s"
Run "kubectl get deployments"
Run "kubectl get pods -l app=my-nginx"

Step "5. Scale to 3 replicas"
Run "kubectl scale deployment my-nginx --replicas=3"
Run "kubectl rollout status deployment/my-nginx --timeout=180s"
Run "kubectl get pods"

Step "6. Rolling update to nginx:1.25"
Run "kubectl set image deployment/my-nginx nginx=nginx:1.25"
Run "kubectl rollout status deployment/my-nginx --timeout=180s"
Run "kubectl rollout history deployment/my-nginx"
Run "kubectl get pods"

if ($ShowRollback) {
    Step "6b. Roll back"
    Run "kubectl rollout undo deployment/my-nginx"
    Run "kubectl rollout status deployment/my-nginx --timeout=180s"
    Run "kubectl rollout history deployment/my-nginx"
}

Step "7. Expose as a NodePort Service"
Run "kubectl expose deployment my-nginx --type=NodePort --port=80"
Run "kubectl get svc"
Note "minikube prints the URL in the new window (on Windows it must stay open to keep the tunnel)."
RunInNewWindow "minikube service my-nginx --url"

Step "Result"
Note "Thus, Kubernetes resources were created and managed using kubectl. A Pod and Deployment were created, scaled, updated, exposed through a Service and cleaned up."
Note "Clean up afterwards with:  powershell -ExecutionPolicy Bypass -File .\exp6-k8s-cli\run.ps1 -Cleanup"
Set-Location $RepoRoot
Stop-Lab
