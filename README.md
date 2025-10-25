# EasyDeploy 🚀

Spin up automated CI/CD for any repository in minutes. One command is all you need:

```bash
./scripts/easydeploy.sh
```

## Quick Start

```bash
# 1. Clone the toolkit (or add it as a submodule)
git clone https://github.com/KahanaT800/cicd-toolkit.git
cd cicd-toolkit

# 2. Launch the main menu and pick “Beginner Setup” or “Quick Install”
./scripts/easydeploy.sh

# 3. Run your first deployment from your project repo
git commit -m "[deploy] Hello EasyDeploy"
git push
```

Need a step-by-step walkthrough? See [docs/README.md](docs/README.md).

## Project Layout

```
scripts/
├── easydeploy.sh            # Main menu & shortcuts
├── init/                    # Installation and onboarding
├── config/                  # Environment checks & GitHub auth
└── deploy/                  # Deployment triggers, status, troubleshooting
config/                      # Default configuration templates
docs/                        # Full documentation set
.github/workflows/           # GitHub Actions pipelines
```

More details live in [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md).

## Essential Scripts

- `./scripts/init/beginner-setup.sh` – Guided setup for first-time users  
- `./scripts/init/install.sh` – Install EasyDeploy into an existing project  
- `./scripts/deploy/auto-deploy.sh` – Commit, branch, API, and manual triggers  
- `./scripts/deploy/status.sh` – Status dashboard and guided demo  
- `./scripts/deploy/troubleshoot.sh` – Detect and resolve workflow conflicts  

A full catalogue is available in [docs/SCRIPTS_GUIDE.md](docs/SCRIPTS_GUIDE.md).

## Documentation

- [📚 Documentation index](docs/README.md) – Pick the right guide quickly  
- [🎓 Beginner Guide](docs/BEGINNER_GUIDE.md) – Zero-to-first-deploy tutorial  
- [⚙️ Configuration Guide](docs/CONFIGURATION.md) – Customize build, deploy, and environments  
- [📘 Auto CI/CD Guide](docs/AUTO_CICD_GUIDE.md) – Trigger logic and workflow anatomy  
- [🧭 FAQ](docs/FAQ.md) – Answers to the most common questions  

Happy shipping! 🎉
