# Experiment 4: Jenkins deployment using Docker

**Aim:** To run Jenkins in Docker, create a Jenkins pipeline that generates a static Karunya University website, publish it inside Jenkins using HTML Publisher and archive the build artifacts.

**Script:** `powershell -ExecutionPolicy Bypass -File .\exp4-jenkins\run.ps1 [-CopyPipeline | -Down]`

It starts Jenkins, waits for it, copies the initial admin password to your clipboard and opens http://localhost:8080.

## Steps

```bash
docker compose up -d
docker compose ps
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
1. http://localhost:8080: paste the password, **Install suggested plugins**, create the admin user.
2. **Manage Jenkins > Plugins > Available plugins**: install **HTML Publisher**.
3. **New Item**: `karunya-site-pipeline`, type **Pipeline**, OK.
4. **Pipeline script**: paste [Jenkinsfile](Jenkinsfile) (`run.ps1 -CopyPipeline` puts it on the clipboard). Save.
   *Alternative:* choose **Pipeline script from SCM**, Git, URL `https://github.com/YOUR_GITHUB_USERNAME/devops-lab.git`, branch `main`, Script Path `exp4-jenkins/Jenkinsfile`.
5. **Build Now**. Open build #1 to see **Karunya University - Simple Site** and **Build Artifacts** (`site/index.html`, `site/assets/style.css`).

Useful: `docker compose logs jenkins`, `docker compose down` (add `-v` only if you want to wipe all Jenkins data).

**Speed tip:** Jenkins setup (plugins) takes several minutes. Run `run.ps1` first in the exam, and do other experiments while it installs.

**If the published page has no colours:** Jenkins' security policy (CSP) blocks CSS in published reports. That's expected; the page and the archived files are still correct. To show it styled for the demo, go to **Manage Jenkins > Script Console** and run
`System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")`, then rebuild.

## Expected output
- `docker compose ps`: `jenkins` is Up, ports 8080 and 50000.
- Pipeline stages **Generate site** and **Publish site** are green.
- The build page has the **Karunya University - Simple Site** link, and `site/**` is listed under Build Artifacts.

**Result:** Thus, Jenkins was deployed using Docker Compose and a pipeline was executed to generate, publish and archive a static website.
