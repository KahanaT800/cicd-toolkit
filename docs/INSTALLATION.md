# EasyDeploy – Installation Guide 🚀

This document walks you through installing EasyDeploy in a project and tailoring the toolkit to your workflow. You do **not** need prior DevOps experience; every step is script-driven.

## 1. Prerequisites

Before you begin, make sure you have:

- A project stored in a Git repository (GitHub or GitHub Enterprise).
- Local access to the project (clone/fork).
- Git, GitHub CLI (`gh`), and common build tools for your language installed on your machine or CI runner.

> Tip: The bundled `scripts/config/environment-setup.sh` script can install and verify most prerequisites for you.

## 2. Install the Toolkit

### Option A – Use the Interactive Menu (recommended)

```bash
# Clone the toolkit alongside your project
git clone https://github.com/KahanaT800/cicd-toolkit.git easydeploy-toolkit
cd easydeploy-toolkit

# Launch the main menu and follow the prompts
./scripts/easydeploy.sh
```

From the menu choose **Beginner Setup** for a guided tour or **Quick Install** if you already know the target project.

### Option B – Run the installer directly

```bash
# Inside the toolkit directory
./scripts/init/install.sh \
  --dir /path/to/your/project \
  --type auto
```

Important flags:

| Flag | Description |
|------|-------------|
| `--dir` | Absolute or relative path to the project you want to configure. Defaults to the current directory. |
| `--type` | Project type (`auto`, `nodejs`, `python`, `java`, `cpp`, `go`, `php`, `ruby`, `docker`, `static`). |
| `--env` | Target environment (`development`, `staging`, `production`). |
| `--skip-deps` | Skip dependency installation (useful in locked-down CI environments). |
| `--verbose` | Emit detailed logs for troubleshooting. |

### Option C – Add as a Git submodule

```bash
cd /path/to/your/project
git submodule add https://github.com/KahanaT800/cicd-toolkit.git .easydeploy

# Run the installer from the submodule
./.easydeploy/scripts/init/install.sh --type auto
```

## 3. What the Installer Creates

After a successful run you will see:

```
your-project/
├── .github/workflows/
│   ├── auto-cicd.yml
│   └── cicd-toolkit.yml
├── scripts/
│   ├── easydeploy.sh
│   ├── init/
│   ├── config/
│   └── deploy/
├── config/
│   ├── universal_config.json
│   └── auto_cicd_config.json
└── docs/ (if requested)
```

All newly added files are committed-ready; review them and adjust as needed before pushing.

## 4. Post-Installation Tasks

### 4.1 Validate your environment

```bash
./scripts/config/environment-setup.sh full
```

This script checks OS details, installs missing packages (where possible), validates Git settings, and runs a quick status check via `./scripts/deploy/status.sh status`.

### 4.2 Configure GitHub authentication

```bash
./scripts/config/github-auth.sh
```

Choose browser or token-based authentication to grant the GitHub CLI access for workflow management and conflict resolution actions.

### 4.3 Review configuration files

- `config/universal_config.json` – High-level project settings such as triggers, environments, notifications, and templates.
- `config/auto_cicd_config.json` – Auto-detected defaults produced during installation; customise build and deploy commands per project type.

Use any editor or `jq` to inspect and modify values:
```bash
jq '.environments' config/universal_config.json
jq '.build_commands' config/auto_cicd_config.json
```

## 5. First Deployment

1. Make a small code change and commit with the deployment keyword:
   ```bash
   git add .
   git commit -m "[deploy] Initial EasyDeploy rollout"
   git push
   ```
2. Watch the workflow run on GitHub Actions. You can also monitor locally:
   ```bash
   ./scripts/deploy/status.sh status
   ```
3. For manual triggers or emergency releases, use the interactive deploy tool:
   ```bash
   ./scripts/deploy/auto-deploy.sh interactive
   ```

## 6. Customising the Installation

### 6.1 Environment-specific behaviour

Each environment block in `config/universal_config.json` controls auto-deploy, approval, and clean-up settings:

```json
{
  "environments": {
    "development": {
      "auto_deploy": true,
      "requires_approval": false
    },
    "staging": {
      "auto_deploy": true,
      "requires_approval": false
    },
    "production": {
      "auto_deploy": false,
      "requires_approval": true
    }
  }
}
```

### 6.2 Project-type templates

The installer loads predefined templates from `config/universal_config.json` → `project_templates`. Override them by editing `config/auto_cicd_config.json` or by re-running the installer with explicit flags (for example `--type python`).

### 6.3 Validate configuration changes

```bash
jq . config/universal_config.json                      # Syntax check
./scripts/deploy/status.sh status                      # Quick workflow smoke test
./scripts/deploy/troubleshoot.sh detect                # Ensure no conflicting runs
```

## 7. Next Steps

- Explore the [Script Guide](SCRIPTS_GUIDE.md) to learn what each helper does.
- Dive into the [Configuration Guide](CONFIGURATION.md) for detailed options.
- Read the [Auto CI/CD Guide](AUTO_CICD_GUIDE.md) to understand workflow internals.

Need help? Check the [FAQ](FAQ.md) or reach out to the team at `support@easydeploy.dev`.
