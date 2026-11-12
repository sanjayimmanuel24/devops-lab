# EXPERIMENT 3 - CI pipeline: Python app -> GitHub Actions -> Docker Hub
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File .\exp3-python-ci-docker\run.ps1
# Local part: run app, run pytest, build + run the Docker image.
# Cloud part: GitHub Actions runs .github/workflows/ci-dockerhub.yml on every push - this script opens the pages.
#   -Trigger   makes a small commit in exp3 and pushes it, so a fresh workflow run starts during the exam.

param(
    [switch]$SkipDocker,
    [switch]$Trigger,
    [switch]$Pause
)

. "$PSScriptRoot\..\scripts\common.ps1"
Start-Lab "exp3-python-ci"
Assert-Tool "python" "Install Python 3.11+."
Set-Location $PSScriptRoot

Step "Project files"
Run "Get-ChildItem -Recurse -Name -Exclude __pycache__,.pytest_cache"
Run "Get-Content app.py"
Run "Get-Content tests\test_app.py"

Step "Run the app and the tests locally"
Run "python app.py"
Run "python -m pip install -q --disable-pip-version-check -r requirements.txt"
Run "python -m pytest -q"
if ($Pause) { Wait-Enter }

if (-not $SkipDocker) {
    Assert-Docker
    $tag = "$DockerHubUser/python-ci-lab:local"
    if ($DockerHubUser -like "YOUR_*") { $tag = "python-ci-lab:local" }
    Step "Build and run the image locally"
    Run "docker build -t $tag ."
    Run "docker run --rm $tag"
    if ($Pause) { Wait-Enter }
}

Set-Location $RepoRoot
if ($Trigger) {
    Step "Trigger a new workflow run (commit + push)"
    Run "Add-Content -Path exp3-python-ci-docker\ci-trigger.txt -Value ('run ' + (Get-Date -Format s))"
    Run "git add exp3-python-ci-docker\ci-trigger.txt"
    Run "git commit -m `"Trigger CI run`""
    Run "git push"
}

Step "GitHub Actions and Docker Hub"
if ($GitHubUser -notlike "YOUR_*") {
    $actions = "https://github.com/$GitHubUser/$GitHubRepo/actions"
    Note "Workflow runs + logs: $actions"
    Start-Process $actions
}
if ($DockerHubUser -notlike "YOUR_*") {
    $hub = "https://hub.docker.com/r/$DockerHubUser/python-ci-lab/tags"
    Note "Published image tags: $hub"
    Start-Process $hub
}
Note "Workflow file: .github\workflows\ci-dockerhub.yml   (manual's version: exp3-python-ci-docker\ci-dockerhub.yml)"

Step "Result"
Note "Thus, a GitHub Actions CI pipeline was configured to test the Python application, build a Docker image and publish it to Docker Hub."
Stop-Lab
