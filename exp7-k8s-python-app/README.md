# Experiment 7: Kubernetes Deployment and Service for a Python app from Docker Hub

**Aim:** To deploy a Python web application stored in Docker Hub to a Kubernetes cluster using a Deployment and a NodePort Service, then access it through Minikube.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp7-k8s-python-app\run.ps1 [-Image user/image:tag] [-Cleanup [-StopCluster]]`

**Image:** the manual's `dockersamples/flaskapp:latest` is no longer on Docker Hub. This uses your own Flask image from Experiment 2,
`YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest` (port 5000). Push it first with `exp2-flask-docker\run.ps1 -Push`.
The script fills in your username from `config.ps1`. By hand, edit the `image:` line in `python-deployment.yaml`.

## Commands (by hand, inside this folder)

```bash
minikube start --driver=docker
kubectl get nodes

kubectl apply -f python-deployment.yaml
kubectl get deployments
kubectl get pods
kubectl describe deployment python-web-deployment

kubectl apply -f python-service.yaml
kubectl get svc
minikube service python-web-service --url      # open the printed URL

minikube stop
minikube delete
```

## Expected output
- `kubectl get nodes`: `Ready`.
- `kubectl get deployments`: `python-web-deployment   2/2`.
- `kubectl get pods`: two `python-web-deployment-...` pods `Running`.
- `kubectl get svc`: `python-web-service   NodePort   ...   5000:3xxxx/TCP`.
- The minikube URL shows "Welcome to Flask + Docker!".

Key points for the viva: the Deployment **selector** `app: python-web` must match the Pod template label. The Service selects Pods by that label. `port` is the Service port, `targetPort` is the container port (5000).

**Result:** Thus, the Python web application image was deployed to Kubernetes using a Deployment with two replicas, exposed through a NodePort Service and accessed using Minikube.
