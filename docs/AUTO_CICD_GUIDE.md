# Auto CI/CD System User Guide

## 📁 File Structure

```
.github/workflows/
├── auto-cicd.yml              # Lightweight auto-deploy workflow
└── cicd-toolkit.yml    # Framework-aware workflow

scripts/
├── easydeploy.sh              # Menu and shortcuts
├── deploy/
│   ├── auto-deploy.sh         # Trigger management (commit/branch/API/manual)
│   ├── status.sh              # Status dashboard and reporting
│   └── troubleshoot.sh        # Conflict detection and resolution
└── config/
    └── github-auth.sh         # GitHub CLI authentication helper

config/
└── auto_cicd_config.json      # Auto-generated project configuration
```

## 🎯 Usage Methods

### 1. Trigger via Commit Message

Include special keywords in commit messages:

```bash
# Basic trigger
git commit -m "[auto-deploy] Fix critical bug"

# Deploy to production
git commit -m "[auto-deploy] [production] Release new version"

# Skip tests and deploy directly
git commit -m "[auto-deploy] [skip-tests] Emergency fix"

# Combined usage
git commit -m "[auto-deploy] [production] [force] Force deploy to production"
```

**Supported Keywords:**
- `[auto-deploy]`, `[deploy]`, `[release]` - Trigger deployment
- `[production]`, `[prod]` - Deploy to production
- `[staging]`, `[stage]` - Deploy to staging
- `[skip-tests]`, `[no-tests]` - Skip tests
- `[force]`, `[force-deploy]` - Force deployment

### 2. Trigger via Special Branches

Create branches with specific prefixes:

```bash
# Auto-deploy branch (deploy to staging)
git checkout -b auto-deploy/feature-x
git push origin auto-deploy/feature-x

# Release candidate branch (deploy to production)
git checkout -b release-candidate/v1.2.0
git push origin release-candidate/v1.2.0

# Hotfix branch
git checkout -b hotfix/critical-fix
git push origin hotfix/critical-fix
```

### 3. Using Trigger Scripts

We provide convenient script tools:

```bash
# Basic usage
./scripts/deploy/auto-deploy.sh commit-trigger

# Deploy to production
./scripts/deploy/auto-deploy.sh commit-trigger -e production

# Skip tests deployment
./scripts/deploy/auto-deploy.sh branch-trigger -s

# API trigger
./scripts/deploy/auto-deploy.sh api-trigger -e staging -f

# Check status
./scripts/deploy/auto-deploy.sh status

# Get help
./scripts/deploy/auto-deploy.sh --help
```

### 4. Trigger via GitHub API

```bash
# Using curl
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/dispatches \
  -d '{
    "event_type": "auto-cicd",
    "client_payload": {
      "environment": "staging",
      "skip_tests": false,
      "force_deploy": false
    }
  }'

# Using GitHub CLI
gh api repos/:owner/:repo/dispatches \
  --method POST \
  --field event_type="deploy-production" \
  --field client_payload='{"skip_tests": false}'
```

### 5. Manual Trigger

1. Visit GitHub Actions page
2. Select "Auto CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Configure parameters and run

## 🔧 Conflict Management

Use the conflict management script to handle CI/CD conflicts:

```bash
# Detect conflicts
./scripts/deploy/troubleshoot.sh detect

# Cancel conflicting CI workflows
./scripts/deploy/troubleshoot.sh cancel

# Smart conflict resolution
./scripts/deploy/troubleshoot.sh resolve HEAD interactive

# Monitor workflow status
./scripts/deploy/troubleshoot.sh monitor "Auto CI/CD Pipeline"

# Generate conflict report
./scripts/deploy/troubleshoot.sh report
```

## ⚙️ Configuration Options

Edit `config/auto_cicd_config.json` to customize settings:

```json
{
  "auto_cicd": {
    "triggers": {
      "commit_keywords": ["[auto-deploy]", "[deploy]"],
      "branch_prefixes": {
        "auto_deploy": "auto-deploy/",
        "release_candidate": "release-candidate/"
      }
    },
    "environments": {
      "staging": {
        "auto_cleanup": true
      },
      "production": {
        "require_approval": true
      }
    }
  }
}
```

## 🔄 Workflow Process

1. **Trigger Detection**: System detects trigger conditions (commit message, branch name, etc.)
2. **Conflict Handling**: Automatically cancels conflicting CI workflows
3. **Quick CI**: Runs simplified CI checks (optional skip)
4. **Build Artifacts**: Builds deployment artifacts
5. **Environment Deployment**: Deploys to specified environment (staging/production)
6. **Result Notification**: Sends deployment result notifications

## 📊 Monitoring and Logs

- **GitHub Actions**: View detailed execution logs
- **Workflow Status**: Use `./scripts/deploy/auto-deploy.sh status` to check recent runs
- **Conflict Reports**: Use `./scripts/deploy/troubleshoot.sh report` to generate analysis reports

## 🚨 Important Notes

1. **Permission Requirements**: Requires appropriate GitHub repository permissions
2. **Token Configuration**: API triggers require Personal Access Token configuration
3. **Environment Preparation**: Ensure target environments are properly configured
4. **Test Validation**: Recommend testing in staging before production deployment
5. **Rollback Preparation**: Maintain rollback mechanism availability

## 🆘 Troubleshooting

### Common Issues

**Q: Workflow not triggered?**
A: Check commit message format, branch names, or run `./scripts/deploy/auto-deploy.sh status`.

**Q: CI workflow conflicts?**
A: Run `./scripts/deploy/troubleshoot.sh detect` and follow the interactive prompts.

**Q: Deployment failed?**
A: Check GitHub Actions logs, verify environment configuration and permission settings

**Q: API trigger not working?**
A: Verify token permissions, check repository settings and API request format

### Getting Help

```bash
# View trigger script help
./scripts/deploy/auto-deploy.sh --help

# View conflict management help
./scripts/deploy/troubleshoot.sh help

# Check workflow status
./scripts/deploy/auto-deploy.sh status
```

## 📈 Best Practices

1. **Test First**: Test in staging environment first, deploy to production after confirmation
2. **Clear Naming**: Use clear commit messages and branch names
3. **Monitor Deployment**: Monitor application status and performance after deployment
4. **Regular Cleanup**: Clean up temporary branches and old deployment packages
5. **Documentation Updates**: Keep deployment documentation and configuration updated

## 🎉 Use Cases

- **Emergency Fixes**: Skip tests for quick deployment of hotfixes
- **Release Management**: Automate version release processes
- **Environment Sync**: Automatically sync staging and production
- **API Integration**: Integrate with external systems to trigger deployments
- **Batch Operations**: Handle multiple deployment tasks in batches

## ⚠️ Prerequisites

- Appropriate GitHub repository permissions
- Recommend testing in staging before production deployment
- Regular checking and cleanup of temporary branches
- Monitor deployment results and application status

## 🔧 Dependencies

- **Git**: Version control system
- **GitHub CLI (optional)**: For API operations and enhanced functionality
- **jq (optional)**: For JSON data processing
- **bash**: Shell environment for script execution
