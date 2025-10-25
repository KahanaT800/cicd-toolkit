# 📁 EasyDeploy Project Structure

All tooling is grouped by responsibility so you can navigate, run, and extend the system efficiently.

```
easydeploy/
├── scripts/                         # 🧰 Executable tooling
│   ├── easydeploy.sh                # 🚀 Main entry point (menu & shortcuts)
│   ├── init/                        # 🔰 Installation and onboarding
│   │   ├── beginner-setup.sh        #   Guided flow for first-time users
│   │   └── install.sh               #   Install EasyDeploy into an existing repo
│   ├── config/                      # ⚙️ Environment and authentication helpers
│   │   ├── environment-setup.sh     #   Dependency checks and system preparation
│   │   └── github-auth.sh           #   GitHub CLI authentication assistant
│   ├── deploy/                      # 🚢 Daily deployment utilities
│   │   ├── auto-deploy.sh           #   Commit / branch / API / manual triggers
│   │   ├── status.sh                #   Status dashboard and guided demo
│   │   └── troubleshoot.sh          #   Conflict detection, cancellation, monitoring
│   └── cicd/README.md               #   Legacy notes kept for compatibility
├── config/
│   ├── universal_config.json        # 📋 Canonical configuration template
│   └── auto_cicd_config.json        # 🔧 Default triggers and environments
├── docs/                            # 📚 Documentation set
│   ├── README.md                    #   Documentation index
│   ├── BEGINNER_GUIDE.md            #   Beginner tutorial
│   ├── INSTALLATION.md              #   Installation manual
│   ├── CONFIGURATION.md             #   Configuration reference
│   ├── SCRIPTS_GUIDE.md             #   Script-by-script usage
│   ├── TROUBLESHOOTING.md           #   Diagnostics and fixes
│   ├── FAQ.md / BEST_PRACTICES.md   #   FAQs and tips
│   └── AUTO_CICD_GUIDE.md …         #   In-depth CI/CD playbook
├── examples/                        # 🎮 Example projects (e.g. Node.js)
├── .github/workflows/               # 🤖 GitHub Actions pipelines
├── README.md                        # 📖 Quick-start overview
└── LICENSE                          # 📄 Project license
```

## 🚀 Recommended Entry Points

```bash
./scripts/easydeploy.sh          # Main menu – everything routes from here
./scripts/init/beginner-setup.sh # First-time users: guided onboarding
./scripts/init/install.sh        # Drop EasyDeploy into an existing repository
./scripts/deploy/auto-deploy.sh  # Trigger deployments or open the status interface
```

## 🔄 Typical Workflow

1. Run `./scripts/easydeploy.sh` and choose **Beginner Setup** or **Quick Install**  
2. Follow the prompts to validate your environment and project configuration  
3. Commit with the trigger keyword when you are ready to deploy:
   ```bash
   git commit -m "[deploy] Release feature X"
   git push
   ```
4. Need a manual trigger or status check? Launch:
   ```bash
   ./scripts/deploy/auto-deploy.sh interactive
   ```

## 🎨 Design Principles

- **Responsibility-based folders** – init, config, and deploy tooling are easy to locate  
- **Single entry point** – `./scripts/easydeploy.sh` is the only command you need to remember  
- **Self-contained scripts** – every script resolves the repository root automatically  
- **Self-explanatory naming** – pair with `docs/SCRIPTS_GUIDE.md` for detailed usage  

---

💡 **Remember:**  
```bash
./scripts/easydeploy.sh
```  
Everything else is accessible from the menu or the categorised script directories.
