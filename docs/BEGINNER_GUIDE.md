# 🔰 EasyDeploy Beginner Guide

Never launched an app before? This guide walks you from “I only have code on my laptop” to “I just shipped a change” in a friendly, step-by-step way.

## 1. What is Deployment?

Deployment is simply **publishing your application so other people (or services) can use it**. Examples:

- 🌐 A website becomes reachable at a public URL.
- 📱 A mobile app build is published for testers or users.
- 🔧 An API runs on a server that clients can call.
- 📊 A dashboard is accessible to your teammates in the browser.

## 2. What You Need

- A project stored in Git (ideally on GitHub).
- Basic terminal access on Windows, macOS, or Linux.
- Internet connectivity to authenticate with GitHub.

That’s it—you don’t need Docker, Kubernetes, or prior CI/CD knowledge.

## 3. Open a Terminal

- **Windows:** Press `Win + R`, type `cmd`, press Enter (or use PowerShell).
- **macOS:** Press `Cmd + Space`, type `terminal`, press Enter.
- **Linux:** Press `Ctrl + Alt + T` to open a terminal window.

## 4. Install EasyDeploy

1. Change into your project directory (replace the path with your own):
   ```bash
   cd /path/to/your/project
   ```
2. Clone the EasyDeploy toolkit alongside your project and launch the menu:
   ```bash
   git clone https://github.com/KahanaT800/cicd-toolkit.git easydeploy-toolkit
   cd easydeploy-toolkit
   ./scripts/easydeploy.sh
   ```
3. Choose **Beginner Setup** in the menu. The wizard will:
   - Detect your project type automatically.
   - Copy the required workflows and helper scripts into your repository.
   - Explain what is happening at each step.

## 5. Make Your First Deployment

Back in your project directory:

```bash
cd /path/to/your/project

git status
# Make a small change if nothing is staged
echo "EasyDeploy is live!" >> README.md

# Deploy using the magic commit keyword
git add .
git commit -m "[deploy] My first EasyDeploy release"
git push
```

EasyDeploy watches for `[deploy]` in commit messages and triggers the GitHub Actions workflow automatically. Open your repository’s **Actions** tab to watch the run, or check locally:

```bash
./scripts/deploy/status.sh status
```

## 6. Alternative Trigger Methods

- **Branch triggers:** Push a branch named `auto-deploy/...`, `release/...`, or `hotfix/...` to start a deployment.
- **Interactive tool:** Run `./scripts/deploy/auto-deploy.sh interactive` to launch a guided CLI that can create commit, branch, API, or manual triggers for you.
- **API trigger:** Use `./scripts/deploy/auto-deploy.sh api-trigger -e staging` to fire a `repository_dispatch` event for integrations.

## 7. Common Questions

### “What if the workflow fails?”
- Use `./scripts/deploy/status.sh status` to inspect recent runs.
- Check GitHub Actions logs for detailed error output.
- Re-run with `./scripts/deploy/auto-deploy.sh interactive` to retry using another trigger.

### “How do I see what changed?”
- Every helper script lives under `scripts/` in your project.
- Workflow files are installed in `.github/workflows/`—open `auto-cicd.yml` to review the pipeline.

### “Can I undo a deployment?”
- Revert the commit locally and push again (`git revert <commit>`).
- Use `./scripts/deploy/auto-deploy.sh interactive` and choose a rollback or redeploy option if you implemented one in your workflow.

## 8. Next Steps

- Read the [Script Cheat Sheet](SCRIPTS_GUIDE.md) for an overview of everything the toolkit can do.
- Explore the [Configuration Guide](CONFIGURATION.md) to customise environments, notifications, and build steps.
- Stuck? Visit the [FAQ](FAQ.md) or email `support@easydeploy.dev`.

Congratulations—you have your first automated deployment pipeline! 🎉
