# Experiment 3: CI pipeline (Python app → GitHub Actions → Docker Hub)

**Aim:** To create a Python application and configure GitHub Actions to run pytest, build a Docker image and push it to Docker Hub.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp3-python-ci-docker\run.ps1 [-Trigger] [-SkipDocker]`

Files: `app.py`, `tests/test_app.py`, `requirements.txt` (pytest==8.3.2), `pytest.ini`, `Dockerfile` (python:3.11-slim).
Workflow that runs: [`/.github/workflows/ci-dockerhub.yml`](../.github/workflows/ci-dockerhub.yml). The manual's exact copy is [`ci-dockerhub.yml`](ci-dockerhub.yml).

Secrets needed (repo **Settings > Secrets and variables > Actions**): `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

## Commands (by hand, inside this folder)

```bash
python app.py
pip install -r requirements.txt
pytest -q
docker build -t YOURNAME/python-ci-lab:local .
docker run --rm YOURNAME/python-ci-lab:local

# push -> triggers the workflow
git add .
git commit -m "init lab"
git push

# optional release tag -> image tagged v1.0.0
git tag v1.0.0
git push origin v1.0.0
```

## Expected output
- `python app.py` prints `Hello from Python CI Lab!` and `2 + 3 = 5`.
- `pytest -q` prints `1 passed`.
- Actions tab: the **ci-dockerhub** run is green, with steps Checkout, Set up Python, Install deps, Run tests, Docker meta, QEMU, Buildx, Login, Build and push.
- Docker Hub: `YOUR_DOCKERHUB_USERNAME/python-ci-lab` with tags `latest` and `sha-xxxxxxx`.

**Result:** Thus, a GitHub Actions CI pipeline was configured to test the Python application, build a Docker image and publish it to Docker Hub.
