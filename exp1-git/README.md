# Experiment 1: Git essentials (commit, push, merge, pull request)

**Aim:** To demonstrate pushing changes to a GitHub repository, including Git setup, repository visibility and basic Git operations.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp1-git\run.ps1 [-RemoteUrl https://github.com/USER/REPO.git] [-Pause]`

It creates a fresh demo project in `%USERPROFILE%\devops-lab-demo\` (outside this repo) and does every step below.
With a remote URL (empty GitHub repo) it also pushes, opens the pull-request page and pulls after you merge.

## Commands (by hand)

```bash
git --version
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

mkdir my-project
cd my-project
git init
echo "Hello Git" > index.html
git status
git add .
git status
git commit -m "Initial commit"
git log

git branch -M main
git remote add origin https://github.com/USERNAME/REPOSITORY.git
git push -u origin main

git checkout -b feature/new-feature
# edit files, then:
git add .
git commit -m "Add new feature"
git checkout main
git merge feature/new-feature
git push origin main

git pull origin main
```

Clone instead of init: `git clone https://github.com/USERNAME/REPOSITORY.git`.
Pull request: push a branch, then on GitHub click **Compare & pull request > Create > Merge**.
Visibility: repo **Settings > Danger Zone > Change repository visibility**.

## Expected output
- `git status` shows "nothing to commit, working tree clean" after the commit.
- `git log` shows the commit history.
- GitHub shows the pushed files and commits.
- The feature-branch change appears on `main` after the merge / PR.

**Result:** Thus, Git was used to initialise/clone a repository, stage and commit changes, create branches, merge work and push/pull changes to GitHub.
