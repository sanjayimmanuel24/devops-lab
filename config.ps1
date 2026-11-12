# Edit these values ONCE. Every run.ps1 script reads them.

$DockerHubUser = "sanjayyyy24"   # e.g. jdoe   (hub.docker.com username)
$GitHubUser    = "sanjayimmanuel24"      # e.g. jdoe   (github.com username)
$GitHubRepo    = "devops-lab"                # name of THIS repo on GitHub

# Used by Experiment 1 only if git has no user.name / user.email yet on the machine.
$GitName  = ""
$GitEmail = ""

# Separate, empty GitHub repo used for the Experiment 1 push / pull-request demo.
# Create it on github.com first (no README), then paste its URL here. Leave "" to skip pushing.
$Exp1RemoteUrl = ""   # e.g. https://github.com/jdoe/git-essentials-demo.git
