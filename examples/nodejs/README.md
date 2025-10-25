# Node.js React Application Example

Example configuration for a React.js application using Universal Auto CI/CD.

## 📁 Project Structure

```
react-app/
├── package.json              # Node.js dependencies
├── src/                      # React source code
├── public/                   # Static assets
├── build/                    # Built application (generated)
└── config/
    └── universal_config.json # CI/CD configuration
```

## ⚙️ Configuration (`config/universal_config.json`)

```json
{
  "project_type": "nodejs",
  "version": "1.0.0",
  "trigger_keywords": ["deploy", "build", "release"],
  "trigger_branches": ["release/*", "deploy/*"],
  "environments": {
    "development": {
      "auto_deploy": true,
      "requires_approval": false,
      "build_commands": [
        "npm ci",
        "npm run lint",
        "npm run build"
      ],
      "deploy_commands": [
        "npm run deploy:dev"
      ],
      "environment_variables": {
        "NODE_ENV": "development",
        "REACT_APP_API_URL": "https://dev-api.example.com"
      }
    },
    "staging": {
      "auto_deploy": true,
      "requires_approval": false,
      "build_commands": [
        "npm ci",
        "npm run lint",
        "npm test -- --coverage",
        "npm run build"
      ],
      "deploy_commands": [
        "npm run deploy:staging"
      ],
      "environment_variables": {
        "NODE_ENV": "staging",
        "REACT_APP_API_URL": "https://staging-api.example.com"
      }
    },
    "production": {
      "auto_deploy": false,
      "requires_approval": true,
      "build_commands": [
        "npm ci",
        "npm run lint",
        "npm test -- --coverage --watchAll=false",
        "npm run build"
      ],
      "deploy_commands": [
        "npm run deploy:prod"
      ],
      "environment_variables": {
        "NODE_ENV": "production",
        "REACT_APP_API_URL": "https://api.example.com"
      }
    }
  },
  "notifications": {
    "slack": {
      "enabled": true,
      "channel": "#frontend-deployments"
    }
  },
  "monitoring": {
    "health_checks": {
      "enabled": true,
      "endpoints": [
        {
          "url": "https://app.example.com/health",
          "timeout": 30
        }
      ]
    }
  }
}
```

## 📦 Package.json Scripts

```json
{
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "lint": "eslint src/",
    "deploy:dev": "aws s3 sync build/ s3://dev-app-bucket/",
    "deploy:staging": "aws s3 sync build/ s3://staging-app-bucket/",
    "deploy:prod": "aws s3 sync build/ s3://prod-app-bucket/"
  }
}
```

## 🚀 Usage Examples

### Trigger via Commit Message

```bash
git commit -m "[deploy] Release new feature"
git push
```

### Trigger via Branch

```bash
git checkout -b release/v1.2.0
git push origin release/v1.2.0
```

### Manual Trigger

```bash
./scripts/deploy/auto-deploy.sh manual-trigger --environment=staging
```

## 🔧 Setup Instructions

1. **Copy this configuration to your React project**:
   ```bash
   cp universal_config.json /path/to/your/react-app/config/
   ```

2. **Install Universal Auto CI/CD**:
   ```bash
   cd /path/to/your/react-app
   curl -sSL https://install.cicd-toolkit.com | bash -s -- --type nodejs
   ```

3. **Customize the configuration**:
   - Update API URLs
   - Configure deployment commands
   - Set up notification channels

4. **Test the setup**:
   ```bash
   ./scripts/deploy/status.sh status
   ```

## 📊 Expected Workflow

1. **Development**: Auto-deploy on every push to `develop` branch
2. **Staging**: Auto-deploy on pushes to `release/*` branches
3. **Production**: Manual approval required, triggered by `[deploy]` commits to `main`

## 🔍 Monitoring

- Health checks verify the application is responding
- Slack notifications for deployment status
- Automatic rollback if health checks fail

---

**This example provides a production-ready setup for React applications with intelligent deployment automation.**