# EXPERIMENT 1 - Git essentials: commit, push, merge and pull request
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File .\exp1-git\run.ps1
# Optional: -RemoteUrl https://github.com/USER/REPO.git   (overrides $Exp1RemoteUrl in config.ps1)
# The demo project is created OUTSIDE this repo, in %USERPROFILE%\devops-lab-demo\my-project-<time>

param(
    [string]$RemoteUrl = "",
    [switch]$Pause
)

. "$PSScriptRoot\..\scripts\common.ps1"
if (-not $RemoteUrl) { $RemoteUrl = $Exp1RemoteUrl }
Start-Lab "exp1-git"
Assert-Tool "git" "Install Git for Windows."

Step "1. Verify and configure Git"
Run "git --version"
$name  = (git config --global user.name)
$email = (git config --global user.email)
if (-not $name -and $GitName)   { Run "git config --global user.name `"$GitName`"" }
if (-not $email -and $GitEmail) { Run "git config --global user.email `"$GitEmail`"" }
Run "git config --global user.name"
Run "git config --global user.email"
if (-not (git config --global user.name) -or -not (git config --global user.email)) {
    Write-Host "Git user.name / user.email are not set. Fill GitName/GitEmail in config.ps1 or run:" -ForegroundColor Red
    Write-Host '  git config --global user.name "Your Name"' -ForegroundColor Red
    Write-Host '  git config --global user.email "you@example.com"' -ForegroundColor Red
    Stop-Lab; exit 1
}
if ($Pause) { Wait-Enter }

Step "2. Create a local repository and commit"
$demoRoot = Join-Path $HOME "devops-lab-demo"
$project  = Join-Path $demoRoot ("my-project-" + (Get-Date -Format "HHmmss"))
New-Item -ItemType Directory -Force -Path $demoRoot | Out-Null
Run "mkdir `"$project`" | Out-Null"
Run "cd `"$project`""
Run "git init"
Run "Set-Content -Path index.html -Value 'Hello Git'"     # same as: echo "Hello Git" > index.html
Run "git status"
Run "git add ."
Run "git status"
Run "git commit -m `"Initial commit`""
Run "git branch -M main"
Run "git log"
if ($Pause) { Wait-Enter }

if ($RemoteUrl) {
    Step "3. Connect to GitHub and push"
    Run "git remote add origin $RemoteUrl"
    Run "git remote -v"
    Run "git push -u origin main"
    if ($Rc -ne 0) {
        Note "Push failed. If the remote already has commits, run: git pull origin main --allow-unrelated-histories, then push again."
        Note "GitHub needs a Personal Access Token (not your password) when it asks for a password."
    }
    if ($Pause) { Wait-Enter }
} else {
    Step "3. Connect to GitHub and push  (SKIPPED - set Exp1RemoteUrl in config.ps1 or pass -RemoteUrl)"
}

Step "4. Branch and merge"
Run "git checkout -b feature/new-feature"
Run "Add-Content -Path index.html -Value 'New feature added on a branch'"
Run "git add ."
Run "git commit -m `"Add new feature`""
Run "git checkout main"
Run "git merge feature/new-feature"
Run "git log --oneline --graph --all"
Run "git branch"
if ($RemoteUrl) { Run "git push origin main" }
if ($Pause) { Wait-Enter }

if ($RemoteUrl) {
    Step "5. Pull request branch"
    Run "git checkout -b feature/pr-demo"
    Run "Add-Content -Path index.html -Value 'Change proposed through a pull request'"
    Run "git add ."
    Run "git commit -m `"Propose change via pull request`""
    Run "git push -u origin feature/pr-demo"
    Run "git checkout main"
    $web = $RemoteUrl -replace '\.git$', ''
    $prUrl = "$web/compare/main...feature/pr-demo?expand=1"
    Note "Open this page, click 'Create pull request', then 'Merge pull request':"
    Write-Host "  $prUrl" -ForegroundColor Green
    Start-Process $prUrl
    Wait-Enter "After merging the PR on GitHub, press Enter to pull it"

    Step "6. Pull remote changes"
    Run "git pull origin main"
    Run "git log --oneline --graph --all"
    Run "Get-Content index.html"
}

Step "Result"
Run "git status"
Note "Thus, Git was used to initialise a repository, stage and commit changes, create branches, merge work and push/pull changes to GitHub."
Note ("Demo project folder: " + $project)
Set-Location $RepoRoot
Stop-Lab
