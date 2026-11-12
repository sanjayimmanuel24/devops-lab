# Experiment 6: Manage Kubernetes resources using the CLI

**Aim:** To install and use Docker, kubectl and Minikube, and manage Kubernetes resources by creating Pods and Deployments, scaling, updating and exposing applications as Services.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp6-k8s-cli\run.ps1 [-ShowRollback] [-Cleanup [-StopCluster]]`

Port-forward and `minikube service --url` never exit, so the script opens each in its own window. Keep those open while showing the page.

## Commands (by hand, inside this folder)

```bash
docker --version
kubectl version --client
minikube start --driver=docker
minikube status
kubectl get nodes

kubectl apply -f nginx-pod.yaml
kubectl get pods
kubectl describe pod nginx-pod
kubectl port-forward pod/nginx-pod 8080:80      # open http://localhost:8080
kubectl delete pod nginx-pod

kubectl create deployment my-nginx --image=nginx
kubectl get deployments
kubectl get pods -l app=my-nginx
kubectl scale deployment my-nginx --replicas=3
kubectl get pods
kubectl set image deployment/my-nginx nginx=nginx:1.25
kubectl rollout status deployment/my-nginx
kubectl rollout undo deployment/my-nginx        # if needed

kubectl expose deployment my-nginx --type=NodePort --port=80
kubectl get svc
minikube service my-nginx --url

kubectl delete svc my-nginx
kubectl delete deployment my-nginx
minikube stop
```

## Expected output
- `kubectl get nodes`: `minikube   Ready`.
- `nginx-pod` is `Running 1/1`; the nginx welcome page shows on localhost:8080.
- After scaling: 3 `my-nginx-...` pods Running; `get deployments` shows `3/3`.
- `rollout status`: `deployment "my-nginx" successfully rolled out`.
- `get svc`: `my-nginx   NodePort   ...   80:3xxxx/TCP`; minikube prints a URL.

**Result:** Thus, Kubernetes resources were created and managed using kubectl. A Pod and Deployment were created, scaled, updated, exposed through a Service and cleaned up.
