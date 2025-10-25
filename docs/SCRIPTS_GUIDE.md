# 📋 EasyDeploy Script Cheat Sheet

Every utility script lives in `scripts/` and is grouped by responsibility. Start with the menu, then drop down to the specific command you need.

## 🎯 Start Here

```bash
./scripts/easydeploy.sh
```

The menu is interactive and also accepts direct subcommands:

```bash
./scripts/easydeploy.sh beginner      # 🔰 Guided onboarding
./scripts/easydeploy.sh install       # ⚡ Quick installation
./scripts/easydeploy.sh deploy        # 🚀 Deployment control panel
./scripts/easydeploy.sh status        # 📊 Status dashboard
./scripts/easydeploy.sh troubleshoot  # 🛠️ Conflict management
```

> ✅ Remember one command and you can reach every other feature.

## 🗂️ Script Catalogue

| Script / Directory | Purpose | Typical Use Case |
|--------------------|---------|------------------|
| `scripts/init/beginner-setup.sh` | Full onboarding wizard | First deployment, training teammates |
| `scripts/init/install.sh` | Install EasyDeploy into an existing repo | Bring CI/CD to any project quickly |
| `scripts/config/environment-setup.sh` | Dependency installation & environment checks | Preparing local or CI machines |
| `scripts/config/github-auth.sh` | GitHub CLI authentication helper | Configure tokens and verify access |
| `scripts/deploy/auto-deploy.sh` | Commit / branch / API / manual triggers | Daily releases, hotfixes, integrations |
| `scripts/deploy/status.sh` | Status dashboard & guided demo | Monitor pipelines, showcase the system |
| `scripts/deploy/troubleshoot.sh` | Conflict detection, cancellation, monitoring, reporting | Resolving competing workflows |

## 🚀 Common Workflows

### First-time experience
```bash
./scripts/easydeploy.sh beginner
# or run the script directly:
./scripts/init/beginner-setup.sh
```

### Install for an existing project
```bash
./scripts/init/install.sh --type auto
# Follow the prompts to select project type and environments
```

### Day-to-day deployments
```bash
git commit -m "[deploy] Fix payment bug"
git push
# or trigger manually:
./scripts/deploy/auto-deploy.sh interactive
```

### Status & troubleshooting
```bash
./scripts/deploy/status.sh status            # Quick health check
./scripts/deploy/troubleshoot.sh detect      # Detect conflicting workflows
./scripts/deploy/troubleshoot.sh interactive # Guided conflict resolution
```

## 💡 Tips

1. **Always start with `./scripts/easydeploy.sh`** – the menu remembers every option for you.  
2. **Keep configuration files under `config/`** – commit updates to `config/universal_config.json` or `config/auto_cicd_config.json` to make pipelines reproducible.  
3. **Mix CLI and CI triggers** – `auto-deploy.sh` supports commit, branch, API, and manual triggers, so you can integrate with existing release flows.  
4. **Run diagnostics early** – `environment-setup.sh`, `github-auth.sh`, and `status.sh` surface environment issues before they block a release.  

---

🎉 Menu-first navigation plus categorised scripts keep CI/CD setup and execution fast and predictable. Explore the rest of `docs/` for deeper guidance when you need it.
