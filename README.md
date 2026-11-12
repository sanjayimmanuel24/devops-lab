# DevOps Lab: all experiments, ready to run

One repo with the code, config and a run script for each lab experiment (1, 2, 3, 4, 6, 7).
Push it to GitHub once. Then on any machine (like the exam PC): **clone it, run a script, show the output.**

| # | Experiment | Folder | Needs |
|---|---|---|---|
| 1 | Git: commit, push, merge, pull request | [exp1-git](exp1-git/) | Git, GitHub |
| 2 | Flask app in Docker, push to Docker Hub | [exp2-flask-docker](exp2-flask-docker/) | Docker Desktop, Docker Hub |
| 3 | CI: pytest + GitHub Actions + Docker Hub | [exp3-python-ci-docker](exp3-python-ci-docker/) + [.github/workflows](.github/workflows/ci-dockerhub.yml) | Python, GitHub secrets |
| 4 | Jenkins in Docker, static-site pipeline | [exp4-jenkins](exp4-jenkins/) | Docker Desktop |
| 6 | Kubernetes CLI: Pod, Deployment, scale, update, Service | [exp6-k8s-cli](exp6-k8s-cli/) | Docker, kubectl, Minikube |
| 7 | Kubernetes Deployment + Service for the Python app | [exp7-k8s-python-app](exp7-k8s-python-app/) | Docker, kubectl, Minikube |

Each script prints every command in **cyan** before running it, so the examiner sees exactly what ran.
It also saves the whole terminal output to `results/` as a text file.

---

## A. One-time setup (on your own laptop)

1. **Fill in your usernames** in [config.ps1](config.ps1) (`DockerHubUser`, `GitHubUser`, and optionally `Exp1RemoteUrl`).
2. **Create the GitHub repo** `devops-lab` on github.com (empty, no README). Then from this folder:
   ```powershell
   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/devops-lab.git
   git push -u origin main
   ```
   When Git asks for a password, use a **Personal Access Token** (GitHub > Settings > Developer settings > Personal access tokens), not your account password.
3. **Add the Actions secrets** for Experiment 3: repo **Settings > Secrets and variables > Actions > New repository secret**:
   - `DOCKERHUB_USERNAME`: your Docker Hub username
   - `DOCKERHUB_TOKEN`: a Docker Hub access token (hub.docker.com > Account settings > Personal access tokens, Read & Write)

   Then **Actions > ci-dockerhub > Run workflow**. A green run here stays visible from any browser.
4. **Create an empty repo for the Experiment 1 demo** (e.g. `git-essentials-demo`) and put its URL in `Exp1RemoteUrl`.
5. **Install tools** (if missing) and check them:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup\install-tools.ps1
   powershell -ExecutionPolicy Bypass -File .\setup\check-tools.ps1
   ```
6. **Do a full rehearsal** of every experiment (section C). Push your Flask image with `exp2 ... -Push`, because Experiment 7 deploys that image.
7. Commit the `results/` files and any screenshots. That's your backup if the exam PC can't run something:
   ```powershell
   git add results
   git commit -m "Lab outputs"
   git push
   ```

## B. On the exam / other machine

```powershell
git clone https://github.com/YOUR_GITHUB_USERNAME/devops-lab.git
cd devops-lab
powershell -ExecutionPolicy Bypass -File .\setup\check-tools.ps1
```
- Start **Docker Desktop** first and wait for "Engine running".
- Use the scripts in section C.
- Things already in the cloud need no setup. Open them in the browser:
  - GitHub repo, commits, PRs: `https://github.com/YOUR_GITHUB_USERNAME/devops-lab`
  - Actions logs: `.../devops-lab/actions`
  - Docker Hub images: `https://hub.docker.com/u/YOUR_DOCKERHUB_USERNAME`
- If the PC has no Docker / Minikube and you can't install, use a browser sandbox: **Play with Docker** (labs.play-with-docker.com, Docker Hub login) or **Killercoda** Kubernetes playground (killercoda.com). `git clone` the repo there and run the commands from each folder's README (they're Linux shells, so use the manual commands, not the `.ps1` scripts).

**When you're done on a shared PC:** `docker logout`, sign out of GitHub / Docker Hub in the browser, and remove `git:https://github.com` from **Windows Credential Manager**.

## C. Commands

Run all of them from the repo root. Add `-Pause` to experiments 1-3 to stop after each step.

```powershell
# Exp 1 - Git (demo repo is created in %USERPROFILE%\devops-lab-demo)
powershell -ExecutionPolicy Bypass -File .\exp1-git\run.ps1

# Exp 2 - Flask + Docker
powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1            # build + run -> http://localhost:5050
powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1 -Push      # + docker login/tag/push
powershell -ExecutionPolicy Bypass -File .\exp2-flask-docker\run.ps1 -PullOnly  # "another machine": pull + run

# Exp 3 - CI
powershell -ExecutionPolicy Bypass -File .\exp3-python-ci-docker\run.ps1           # app, pytest, docker build/run, opens Actions
powershell -ExecutionPolicy Bypass -File .\exp3-python-ci-docker\run.ps1 -Trigger  # + push a commit -> fresh workflow run

# Exp 4 - Jenkins
powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1                # compose up, password -> clipboard, opens :8080
powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1 -CopyPipeline  # Jenkinsfile -> clipboard
powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1 -Down

# Exp 6 - Kubernetes CLI
powershell -ExecutionPolicy Bypass -File .\exp6-k8s-cli\run.ps1 -ShowRollback
powershell -ExecutionPolicy Bypass -File .\exp6-k8s-cli\run.ps1 -Cleanup

# Exp 7 - Kubernetes Python app
powershell -ExecutionPolicy Bypass -File .\exp7-k8s-python-app\run.ps1
powershell -ExecutionPolicy Bypass -File .\exp7-k8s-python-app\run.ps1 -Cleanup -StopCluster
```

## Differences from the manual (and why)

- **Exp 3:** added `pytest.ini` (`pythonpath = .`). Without it, plain `pytest -q` can't import `app.py` from `tests/` and the CI run fails. The workflow in `.github/workflows` points at the `exp3-python-ci-docker` folder, because this repo holds every experiment. The manual's exact version is kept in `exp3-python-ci-docker/ci-dockerhub.yml` to write in the exam.
- **Exp 7:** the manual's image `dockersamples/flaskapp` no longer exists on Docker Hub (checked Nov 2026). The Deployment uses your own Exp 2 image `YOUR_DOCKERHUB_USERNAME/flask-docker-app:latest`, which also listens on port 5000. Mention this if asked.
- **Exp 2:** the script runs the container with `-d` (detached) so the terminal stays free; the manual runs it in the foreground. Same result.
