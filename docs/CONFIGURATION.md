# EasyDeploy - Configuration Guide 🛠️

Learn how to customize EasyDeploy to work perfectly with your project. Don't worry - the defaults work great, but these options let you make it even better!

## 📁 Configuration Files (The Easy Way)

### Main Settings (`config/universal_config.json`)

This is the main file that controls how EasyDeploy works. Here's what a typical setup looks like:

```json
{
  "project_name": "EasyDeploy",
  "project_type": "auto-detect",           // Let EasyDeploy figure it out!
  "version": "2.0.0",
  "description": "Deploy your apps effortlessly!",
  "trigger_keywords": ["deploy", "build", "release", "publish", "ship"],
  "trigger_branches": ["release/*", "deploy/*", "hotfix/*", "production/*"],
  "environments": { /* where your app gets deployed */ },
  "project_templates": { /* ready-made setups */ },
  "conflict_resolution": { /* prevents problems */ },
  "notifications": { /* keep you informed */ },
  "security": { /* keep things safe */ },
  "monitoring": { /* see what's happening */ },
  "beginner_features": { /* extra help for new users */ }
}
```

### Advanced Settings (`config/auto_cicd_config.json`)

This file has more detailed options. Most people don't need to touch this!

## 🎯 Basic Configuration (Start Here!)

### Let EasyDeploy Detect Your Project Type

```json
{
  "project_type": "auto-detect"
}
```

This is the magic setting! EasyDeploy will look at your files and figure out:
- 📱 **nodejs** - If you have `package.json`
- 🐍 **python** - If you have `requirements.txt` or `setup.py`
- ☕ **java** - If you have `pom.xml` or `build.gradle`
- ⚡ **cpp** - If you have `CMakeLists.txt` or `Makefile`
- 🐹 **go** - If you have `go.mod`
- 🐘 **php** - If you have `composer.json`
- 💎 **ruby** - If you have `Gemfile`
- 🐳 **docker** - If you have `Dockerfile`

**💡 Pro Tip:** Just leave it as `auto-detect` unless you have a very specific reason to change it!
- `generic` - Generic projects

### Trigger Configuration

#### Commit Message Triggers

```json
{
  "trigger_keywords": [
    "deploy",     // [deploy] Deploy to production
    "build",      // [build] Build and test
    "release",    // [release] Release version 1.0.0
    "publish",    // [publish] Publish to registry
    "ship",       // [ship] Ship to customers
    "hotfix"      // [hotfix] Emergency fix
  ]
}
```

#### Branch Pattern Triggers

```json
{
  "trigger_branches": [
    "release/*",      // release/v1.0.0, release/hotfix
    "deploy/*",       // deploy/staging, deploy/production
    "hotfix/*",       // hotfix/urgent-fix, hotfix/security
    "production/*"    // production/deploy, production/rollback
  ]
}
```

## 🌍 Environment Configuration

### Basic Environment Setup

```json
{
  "environments": {
    "development": {
      "auto_deploy": true,
      "requires_approval": false,
      "build_commands": ["npm run build:dev"],
      "deploy_commands": ["npm run deploy:dev"],
      "environment_variables": {
        "NODE_ENV": "development",
        "DEBUG": "true"
      }
    },
    "staging": {
      "auto_deploy": true,
      "requires_approval": false,
      "build_commands": ["npm run build:staging"],
      "deploy_commands": ["npm run deploy:staging"],
      "environment_variables": {
        "NODE_ENV": "staging"
      }
    },
    "production": {
      "auto_deploy": false,
      "requires_approval": true,
      "build_commands": ["npm run build:prod"],
      "deploy_commands": ["npm run deploy:prod"],
      "environment_variables": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### Environment Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `auto_deploy` | boolean | Enable automatic deployment | `false` |
| `requires_approval` | boolean | Require manual approval | `true` |
| `build_commands` | array | Custom build commands | `[]` |
| `deploy_commands` | array | Custom deployment commands | `[]` |
| `environment_variables` | object | Environment-specific variables | `{}` |
| `timeout` | number | Deployment timeout (minutes) | `30` |
| `retry_count` | number | Number of retry attempts | `3` |

## 🛠️ Project Templates

### Node.js Configuration

```json
{
  "project_templates": {
    "nodejs": {
      "build_commands": [
        "npm ci",
        "npm run lint",
        "npm run build",
        "npm test"
      ],
      "deploy_commands": [
        "npm run deploy"
      ],
      "artifacts": [
        "dist/",
        "build/"
      ],
      "cache_paths": [
        "node_modules/",
        ".npm/"
      ]
    }
  }
}
```

### Python Configuration

```json
{
  "project_templates": {
    "python": {
      "build_commands": [
        "pip install -r requirements.txt",
        "python -m flake8 .",
        "python -m pytest",
        "python setup.py build"
      ],
      "deploy_commands": [
        "python -m pip install --upgrade .",
        "python deploy.py"
      ],
      "artifacts": [
        "dist/",
        "build/"
      ],
      "cache_paths": [
        ".cache/pip/",
        "__pycache__/"
      ]
    }
  }
}
```

### Java Configuration

```json
{
  "project_templates": {
    "java": {
      "build_commands": [
        "./mvnw clean compile",
        "./mvnw test",
        "./mvnw package"
      ],
      "deploy_commands": [
        "./mvnw deploy"
      ],
      "artifacts": [
        "target/"
      ],
      "cache_paths": [
        ".m2/"
      ]
    }
  }
}
```

### C++ Configuration

```json
{
  "project_templates": {
    "cpp": {
      "build_commands": [
        "mkdir -p build",
        "cd build && cmake ..",
        "cd build && make",
        "cd build && ctest"
      ],
      "deploy_commands": [
        "cd build && make install"
      ],
      "artifacts": [
        "build/",
        "bin/"
      ]
    }
  }
}
```

### Go Configuration

```json
{
  "project_templates": {
    "go": {
      "build_commands": [
        "go mod tidy",
        "go vet ./...",
        "go test ./...",
        "go build ."
      ],
      "deploy_commands": [
        "go install ."
      ],
      "artifacts": [
        "bin/",
        "dist/"
      ],
      "cache_paths": [
        ".cache/go-build/"
      ]
    }
  }
}
```

## ⚔️ Conflict Resolution

### Conflict Resolution Strategies

```json
{
  "conflict_resolution": {
    "strategy": "cancel_ci",
    "wait_timeout": 300,
    "retry_attempts": 3,
    "strategies": [
      "cancel_ci",    // Cancel conflicting CI workflows
      "wait",         // Wait for conflicts to resolve
      "interactive"   // Manual intervention required
    ]
  }
}
```

### Strategy Options

- **cancel_ci**: Automatically cancel running CI workflows that might conflict
- **wait**: Wait for conflicting workflows to complete before proceeding
- **interactive**: Pause and require manual intervention to resolve conflicts

## 🔔 Notifications

### Slack Integration

```json
{
  "notifications": {
    "slack": {
      "enabled": true,
      "webhook_url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
      "channel": "#deployments",
      "username": "Auto CI/CD Bot",
      "notify_on": ["success", "failure", "start"],
      "mention_on_failure": ["@devops-team"]
    }
  }
}
```

### Discord Integration

```json
{
  "notifications": {
    "discord": {
      "enabled": true,
      "webhook_url": "https://discord.com/api/webhooks/YOUR/WEBHOOK",
      "notify_on": ["success", "failure"],
      "avatar_url": "https://example.com/bot-avatar.png"
    }
  }
}
```

### Email Notifications

```json
{
  "notifications": {
    "email": {
      "enabled": true,
      "smtp_server": "smtp.gmail.com",
      "smtp_port": 587,
      "username": "notifications@yourcompany.com",
      "recipients": [
        "team@yourcompany.com",
        "ops@yourcompany.com"
      ],
      "notify_on": ["failure", "success"]
    }
  }
}
```

### Microsoft Teams Integration

```json
{
  "notifications": {
    "teams": {
      "enabled": true,
      "webhook_url": "https://outlook.office.com/webhook/YOUR/WEBHOOK",
      "notify_on": ["success", "failure", "approval_required"]
    }
  }
}
```

## 🔐 Security Configuration

### Access Control

```json
{
  "security": {
    "require_signed_commits": true,
    "allowed_users": [
      "admin",
      "devops-team"
    ],
    "allowed_teams": [
      "developers",
      "operations"
    ],
    "protected_branches": [
      "main",
      "master",
      "production"
    ],
    "require_reviews": {
      "production": 2,
      "staging": 1
    }
  }
}
```

### Secrets Management

```json
{
  "security": {
    "required_secrets": [
      "DEPLOY_TOKEN",
      "DATABASE_URL",
      "API_KEY"
    ],
    "secret_validation": true
  }
}
```

## 📊 Monitoring Configuration

### Health Checks

```json
{
  "monitoring": {
    "health_checks": {
      "enabled": true,
      "endpoints": [
        {
          "url": "https://api.yourapp.com/health",
          "timeout": 30,
          "retry_count": 3,
          "expected_status": 200
        }
      ],
      "post_deploy_wait": 60
    }
  }
}
```

### Automatic Rollback

```json
{
  "monitoring": {
    "rollback": {
      "enabled": true,
      "automatic": false,
      "conditions": [
        "health_check_failed",
        "error_rate_high",
        "response_time_high"
      ],
      "rollback_timeout": 300
    }
  }
}
```

## 🚀 Advanced Configuration

### Performance Optimization

```json
{
  "advanced": {
    "parallel_jobs": 4,
    "cache_enabled": true,
    "cache_paths": [
      "node_modules/",
      ".cache/",
      "vendor/"
    ],
    "artifact_retention_days": 7,
    "build_timeout": 30,
    "deploy_timeout": 15
  }
}
```

### Custom Hooks

```json
{
  "advanced": {
    "before_hooks": [
      "echo 'Starting deployment'",
      "./scripts/pre-deploy.sh"
    ],
    "after_hooks": [
      "./scripts/post-deploy.sh",
      "echo 'Deployment complete'"
    ]
  }
}
```

### Environment Variables

```json
{
  "advanced": {
    "custom_env_vars": {
      "DEPLOY_TIMESTAMP": "$(date +%s)",
      "BUILD_NUMBER": "${{ github.run_number }}",
      "COMMIT_SHA": "${{ github.sha }}"
    }
  }
}
```

## 🔧 Configuration Examples

### Microservices Setup

```json
{
  "project_type": "nodejs",
  "environments": {
    "development": {
      "auto_deploy": true,
      "services": ["api", "web", "worker"]
    },
    "production": {
      "auto_deploy": false,
      "requires_approval": true,
      "services": ["api", "web", "worker"],
      "deployment_strategy": "rolling"
    }
  }
}
```

### Multi-Language Project

```json
{
  "project_type": "multi",
  "services": {
    "frontend": {
      "type": "nodejs",
      "build_commands": ["npm run build"]
    },
    "backend": {
      "type": "python",
      "build_commands": ["pip install -r requirements.txt"]
    },
    "database": {
      "type": "docker",
      "build_commands": ["docker build -t myapp-db ."]
    }
  }
}
```

## ✅ Configuration Validation

### Validate Configuration

```bash
# Validate JSON syntax
jq . config/universal_config.json

# Run a lightweight status check
./scripts/deploy/status.sh status

# Inspect individual sections
jq '.environments' config/universal_config.json
```

### Common Validation Errors

1. **Invalid JSON syntax**
   ```bash
   # Fix: Check for missing commas, quotes, brackets
   jq . config/universal_config.json
   ```

2. **Missing required fields**
   ```bash
   # Fix: Ensure all required fields are present
   jq '.project_type // "missing"' config/universal_config.json
   ```

3. **Invalid environment names**
   ```bash
   # Fix: Use valid environment names (development, staging, production)
   jq '.environments | keys' config/universal_config.json
   ```

## 📝 Configuration Templates

### Quick-Start Templates

Templates are defined inside `config/universal_config.json` under `project_templates`. Copy the block that matches your stack into `config/auto_cicd_config.json` and adjust build or deploy commands as needed. For example:

```bash
jq '.project_templates.nodejs' config/universal_config.json > config/auto_cicd_config.json
```

### Environment-Specific Layouts

Want separate files per environment? Create additional JSON files (for example `config/environments/production.json`) and merge them during installation:

```bash
cat config/universal_config.json config/environments/production.json \
  | jq -s '.[0] * .[1]' > config/auto_cicd_config.json
```

---

**Need help with configuration? Check our [troubleshooting guide](TROUBLESHOOTING.md) or [ask the community](https://discord.gg/cicd-toolkit).**
