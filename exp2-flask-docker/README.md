# Experiment 2: Flask application containerization and Docker Hub deployment

**Aim:** To create a Flask web application, containerize it using Docker and publish the Docker image to Docker Hub.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1 [-Push | -PullOnly] [-HostPort 5050]`

Files: `app.py` (Flask, listens on 0.0.0.0:5000), `requirements.txt` (Flask==2.2.5), `Dockerfile`.

## Commands (by hand, inside this folder)

```bash
docker build -t flask-docker-app .
docker images
docker run -p 5050:5000 flask-docker-app
# open http://localhost:5050

docker login
docker tag flask-docker-app YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest
docker push YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest

# on another machine
docker pull YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest
docker run -p 5050:5000 YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest
```

## Expected output
- `docker images` lists `flask-docker-app`.
- `docker ps` shows the running container with `0.0.0.0:5050->5000/tcp`.
- http://localhost:5050 shows "Welcome to Flask + Docker!".
- The image appears in your Docker Hub repository after pushing.

Port busy? Use `-HostPort 5051` (i.e. `-p 5051:5000`).

**Result:** Thus, the Flask web application was successfully containerized, executed as a Docker container and uploaded to Docker Hub.
