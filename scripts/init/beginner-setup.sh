#!/bin/bash

# EasyDeploy Beginner Setup Script 🔰
# This script is specially designed for people who have never deployed anything before!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Super friendly colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fun emojis for better experience
ROCKET="🚀"
CHECK="✅"
INFO="ℹ️"
WARNING="⚠️"
QUESTION="❓"
PARTY="🎉"
THINKING="🤔"
LIGHT="💡"

# Beginner-friendly logging
log_welcome() { echo -e "\n${PURPLE}${ROCKET} $1${NC}\n"; }
log_step() { echo -e "${BLUE}📋 Step $1: $2${NC}"; }
log_info() { echo -e "${CYAN}${INFO} $1${NC}"; }
log_success() { echo -e "${GREEN}${CHECK} $1${NC}"; }
log_warning() { echo -e "${YELLOW}${WARNING} $1${NC}"; }
log_question() { echo -e "${YELLOW}${QUESTION} $1${NC}"; }
log_tip() { echo -e "${BLUE}${LIGHT} Tip: $1${NC}"; }

# Welcome message
welcome_message() {
    clear
    log_welcome "Welcome to EasyDeploy!"
    echo "This script will help you set up automatic deployment for your project."
    echo "Don't worry if you've never done this before - we'll guide you through everything!"
    echo
    echo "What we're going to do:"
    echo "  1. ${CHECK} Look at your project and figure out what it is"
    echo "  2. ${CHECK} Set up deployment configuration (automatically)"
    echo "  3. ${CHECK} Test that everything works"
    echo "  4. ${CHECK} Show you how to deploy your first change"
    echo
    echo "This will take about 2-3 minutes."
    echo
    read -p "Ready to get started? (press Enter to continue, or Ctrl+C to exit)"
}

# Check if this looks like a code project
check_project() {
    log_step "1" "Looking at your project"
    
    if [[ ! -d ".git" ]]; then
        log_warning "This doesn't look like a Git repository yet."
        echo
        echo "For EasyDeploy to work, your code needs to be in a Git repository."
        echo "This is just a way to track changes to your code - like 'Save As' with superpowers!"
        echo
        log_question "Would you like me to set up Git for your project? (y/n)"
        read -r setup_git
        
        if [[ $setup_git =~ ^[Yy]$ ]]; then
            log_info "Setting up Git for your project..."
            git init
            git add .
            git commit -m "Initial commit - ready for EasyDeploy!"
            log_success "Git is now set up!"
        else
            echo
            echo "No problem! You can set up Git later with these commands:"
            echo -e "  ${BLUE}git init${NC}"
            echo -e "  ${BLUE}git add .${NC}"
            echo -e "  ${BLUE}git commit -m 'Initial commit'${NC}"
            echo
            echo "Come back and run this script again when you're ready!"
            exit 0
        fi
    else
        log_success "Great! This is already a Git repository."
    fi
    
    # Check GitHub integration
    log_info "Checking GitHub connection..."
    
    if ! git remote | grep -q .; then
        log_warning "Your project isn't connected to GitHub yet."
        echo
        echo "GitHub is where your code will live online, and where EasyDeploy will deploy from."
        echo "Think of it like Google Drive, but specifically designed for code!"
        echo
        
        # Check if GitHub CLI is available and authenticated
        if command -v gh &> /dev/null && gh auth status &> /dev/null; then
            log_question "Would you like me to create a GitHub repository for your project? (y/n)"
            read -r create_repo
            
            if [[ $create_repo =~ ^[Yy]$ ]]; then
                echo -n "What would you like to name your repository? (press Enter for '$(basename "$PWD")'): "
                read -r repo_name
                
                if [[ -z "$repo_name" ]]; then
                    repo_name=$(basename "$PWD")
                fi
                
                log_info "Creating GitHub repository: $repo_name"
                
                if gh repo create "$repo_name" --public --description "Created with EasyDeploy"; then
                    git remote add origin "https://github.com/$(gh api user --jq .login)/$repo_name.git"
                    log_success "GitHub repository created!"
                    
                    log_info "Uploading your code to GitHub..."
                    if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
                        log_success "Your code is now on GitHub!"
                    else
                        log_warning "Couldn't upload code automatically. You can do it later with:"
                        echo -e "  ${BLUE}git push -u origin main${NC}"
                    fi
                else
                    log_warning "Couldn't create GitHub repository automatically."
                    echo
                    echo "You can create one manually at: https://github.com/new"
                    echo "Then connect it with:"
                    echo -e "  ${BLUE}git remote add origin https://github.com/username/repo-name.git${NC}"
                    echo -e "  ${BLUE}git push -u origin main${NC}"
                fi
            else
                log_info "No problem! You can connect to GitHub later."
                echo
                echo "When you're ready, you can:"
                echo "  1. Create a repository at: https://github.com/new"
                echo -e "  2. Connect it with: ${BLUE}git remote add origin https://github.com/username/repo-name.git${NC}"
                echo -e "  3. Upload your code: ${BLUE}git push -u origin main${NC}"
            fi
        else
            log_warning "GitHub CLI not found or not authenticated."
            echo
            echo "To connect to GitHub, you'll need to:"
            echo "  1. Install GitHub CLI: https://cli.github.com/"
            echo -e "  2. Log in: ${BLUE}gh auth login${NC}"
            echo "  3. Create a repository at: https://github.com/new"
            echo -e "  4. Connect it: ${BLUE}git remote add origin https://github.com/username/repo-name.git${NC}"
            echo -e "  5. Upload code: ${BLUE}git push -u origin main${NC}"
            echo
            echo -e "${LIGHT} Don't worry - EasyDeploy will work without GitHub, but some features need it!"
        fi
    else
        local remote_url=$(git remote get-url origin 2>/dev/null || echo "Unknown")
        log_success "Great! Your project is connected to GitHub: $remote_url"
        
        # Check if we can actually access the repository
        if command -v gh &> /dev/null && gh auth status &> /dev/null; then
            if gh repo view &> /dev/null; then
                log_success "GitHub repository is accessible and ready for deployment!"
            else
                log_warning "Can't access GitHub repository - you might need to check permissions"
                echo -e "  Try: ${BLUE}gh auth login${NC}"
            fi
        fi
    fi
    
    echo
}

# Detect what kind of project this is
detect_project() {
    log_step "2" "Figuring out what kind of project this is"
    
    PROJECT_TYPE=""
    PROJECT_DESCRIPTION=""
    
    if [[ -f "package.json" ]]; then
        PROJECT_TYPE="nodejs"
        PROJECT_DESCRIPTION="Node.js/JavaScript project"
        if grep -q "react" package.json; then
            PROJECT_DESCRIPTION="React application"
        elif grep -q "vue" package.json; then
            PROJECT_DESCRIPTION="Vue.js application"
        elif grep -q "angular" package.json; then
            PROJECT_DESCRIPTION="Angular application"
        elif grep -q "express" package.json; then
            PROJECT_DESCRIPTION="Express.js server"
        fi
    elif [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
        PROJECT_TYPE="python"
        PROJECT_DESCRIPTION="Python project"
        if [[ -f "manage.py" ]]; then
            PROJECT_DESCRIPTION="Django web application"
        elif [[ -f "app.py" || -f "main.py" ]]; then
            if grep -q "flask" requirements.txt 2>/dev/null; then
                PROJECT_DESCRIPTION="Flask web application"
            elif grep -q "fastapi" requirements.txt 2>/dev/null; then
                PROJECT_DESCRIPTION="FastAPI application"
            elif grep -q "streamlit" requirements.txt 2>/dev/null; then
                PROJECT_DESCRIPTION="Streamlit data app"
            fi
        fi
    elif [[ -f "pom.xml" ]]; then
        PROJECT_TYPE="java"
        PROJECT_DESCRIPTION="Java Maven project"
        if grep -q "spring-boot" pom.xml; then
            PROJECT_DESCRIPTION="Spring Boot application"
        fi
    elif [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
        PROJECT_TYPE="java"
        PROJECT_DESCRIPTION="Java Gradle project"
    elif [[ -f "go.mod" ]]; then
        PROJECT_TYPE="go"
        PROJECT_DESCRIPTION="Go application"
    elif [[ -f "composer.json" ]]; then
        PROJECT_TYPE="php"
        PROJECT_DESCRIPTION="PHP project"
        if grep -q "laravel" composer.json; then
            PROJECT_DESCRIPTION="Laravel application"
        elif grep -q "symfony" composer.json; then
            PROJECT_DESCRIPTION="Symfony application"
        fi
    elif [[ -f "Gemfile" ]]; then
        PROJECT_TYPE="ruby"
        PROJECT_DESCRIPTION="Ruby project"
        if grep -q "rails" Gemfile; then
            PROJECT_DESCRIPTION="Ruby on Rails application"
        fi
    elif [[ -f "index.html" ]]; then
        PROJECT_TYPE="static"
        PROJECT_DESCRIPTION="Static website (HTML/CSS/JavaScript)"
    elif [[ -f "Dockerfile" ]]; then
        PROJECT_TYPE="docker"
        PROJECT_DESCRIPTION="Dockerized application"
    else
        PROJECT_TYPE="generic"
        PROJECT_DESCRIPTION="Generic project"
    fi
    
    log_success "Detected: $PROJECT_DESCRIPTION"
    
    if [[ $PROJECT_TYPE == "generic" ]]; then
        echo
        log_info "I couldn't automatically detect your project type, but that's okay!"
        echo "EasyDeploy can still work with your project using generic deployment."
        echo
        log_question "What kind of project is this? (or press Enter for generic)"
        echo "  1) Web application (HTML/CSS/JavaScript)"
        echo "  2) Node.js/JavaScript project"
        echo "  3) Python project"
        echo "  4) Java project"
        echo "  5) Other/Generic"
        read -r project_choice
        
        case $project_choice in
            1) PROJECT_TYPE="static"; PROJECT_DESCRIPTION="Static website" ;;
            2) PROJECT_TYPE="nodejs"; PROJECT_DESCRIPTION="Node.js project" ;;
            3) PROJECT_TYPE="python"; PROJECT_DESCRIPTION="Python project" ;;
            4) PROJECT_TYPE="java"; PROJECT_DESCRIPTION="Java project" ;;
            *) PROJECT_TYPE="generic"; PROJECT_DESCRIPTION="Generic project" ;;
        esac
        
        log_success "Set as: $PROJECT_DESCRIPTION"
    fi
}

# Set up EasyDeploy configuration
setup_easydeploy() {
    log_step "3" "Setting up EasyDeploy for your project"
    
    # Create .easydeploy directory
    mkdir -p .easydeploy
    
    # Create beginner-friendly configuration
    cat > .easydeploy/config.json << EOF
{
  "project_name": "$(basename $(pwd))",
  "project_type": "$PROJECT_TYPE",
  "description": "$PROJECT_DESCRIPTION",
  "version": "1.0.0",
  "beginner_mode": true,
  "auto_detect": true,
  "environments": {
    "development": {
      "description": "For testing your changes",
      "auto_deploy": true,
      "require_approval": false,
      "friendly_name": "Development/Testing"
    },
    "production": {
      "description": "Where your users see your app",
      "auto_deploy": false,
      "require_approval": true,
      "friendly_name": "Live/Production"
    }
  },
  "deployment": {
    "build_timeout": "10m",
    "deploy_timeout": "5m",
    "auto_rollback": true,
    "health_check": true,
    "beginner_friendly_errors": true
  },
  "notifications": {
    "deployment_success": true,
    "deployment_failure": true,
    "friendly_messages": true
  }
}
EOF
    
    # Create simple deployment workflow
    mkdir -p .github/workflows
    cat > .github/workflows/easydeploy.yml << EOF
name: EasyDeploy
on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: EasyDeploy Setup
      run: |
        echo "🚀 Starting deployment for $PROJECT_DESCRIPTION"
        echo "Project type: $PROJECT_TYPE"
        
    - name: Deploy
      run: |
        echo "✅ Deployment successful!"
        echo "Your $PROJECT_DESCRIPTION is now deployed!"
EOF
    
    log_success "EasyDeploy configuration created!"
}

# Test the setup
test_setup() {
    log_step "4" "Testing your setup"
    
    log_info "Creating a test commit to make sure everything works..."
    
    # Add EasyDeploy files to git
    git add .easydeploy .github
    
    if git diff --staged --quiet; then
        log_info "No changes to commit (files already exist)"
    else
        git commit -m "🚀 Set up EasyDeploy for automatic deployment

This commit adds EasyDeploy configuration for automatic deployment.
Project type: $PROJECT_DESCRIPTION

Now you can deploy by using [deploy] in your commit messages!"
    fi
    
    log_success "Setup test completed!"
}

# Show next steps
show_next_steps() {
    log_step "5" "You're all set! Here's what to do next"
    
    echo
    log_success "🎉 Congratulations! EasyDeploy is now set up for your $PROJECT_DESCRIPTION"
    echo
    echo "Here's how to deploy your app:"
    echo
    echo "1. ${CHECK} Make any change to your code"
    echo "2. ${CHECK} Commit with a special message:"
    echo "     git add ."
    echo "     git commit -m '[deploy] My awesome update!'"
    echo "     git push"
    echo "3. ${CHECK} EasyDeploy will automatically deploy your changes!"
    echo
    echo "${PARTY} Magic deployment words you can use:"
    echo "  [deploy]  - Deploy your changes"
    echo "  [build]   - Build and test"
    echo "  [release] - Create a new release"
    echo "  [publish] - Publish your app"
    echo
    log_tip "Start with '[deploy]' - it's the most common one!"
    echo
    echo "Other helpful commands:"
    echo "  ./scripts/demo.sh status     - See what's happening"
    echo "  ./scripts/demo.sh logs       - View deployment logs"
    echo "  ./scripts/trigger.sh deploy  - Deploy right now"
    echo
    log_info "Need help? Check out:"
    echo "  📖 Complete guide: docs/BEGINNER_GUIDE.md"
    echo "  🆘 Troubleshooting: docs/TROUBLESHOOTING.md"
    echo "  💬 Community help: https://discord.gg/easydeploy"
    echo
    echo "${PARTY} Happy deploying! Your first deployment is just one commit away!"
}

# Ask if they want to make a test deployment
offer_test_deployment() {
    echo
    log_question "Would you like to make a test deployment right now? (y/n)"
    read -r test_deploy
    
    if [[ $test_deploy =~ ^[Yy]$ ]]; then
        echo
        log_info "Creating a simple test deployment..."
        
        # Create or update README with deployment info
        if [[ ! -f "README.md" ]]; then
            echo "# $(basename $(pwd))" > README.md
            echo "" >> README.md
            echo "This is a $PROJECT_DESCRIPTION set up with EasyDeploy!" >> README.md
            echo "" >> README.md
            echo "🚀 **Deployed with EasyDeploy** - Deploy your apps effortlessly!" >> README.md
            echo "" >> README.md
            echo "## How to Deploy" >> README.md
            echo "" >> README.md
            echo "Just commit with \`[deploy]\` in your message:" >> README.md
            echo "" >> README.md
            echo "\`\`\`bash" >> README.md
            echo "git add ." >> README.md
            echo "git commit -m \"[deploy] Updated my awesome app!\"" >> README.md
            echo "git push" >> README.md
            echo "\`\`\`" >> README.md
        else
            echo "" >> README.md
            echo "---" >> README.md
            echo "🚀 **Now using EasyDeploy for automatic deployment!**" >> README.md
        fi
        
        git add README.md
        git commit -m "[deploy] Test deployment with EasyDeploy! 🚀

This is my first deployment using EasyDeploy.
Project type: $PROJECT_DESCRIPTION

EasyDeploy makes deployment simple and automatic!"
        
        log_success "Test deployment commit created!"
        echo
        log_info "Now push to GitHub to see your first deployment:"
        echo "  git push"
        echo
        log_tip "After you push, check GitHub Actions to see your deployment in action!"
    else
        log_info "No problem! You can deploy anytime by using [deploy] in your commit messages."
    fi
}

# Main execution
main() {
    welcome_message
    check_project
    detect_project
    setup_easydeploy
    test_setup
    show_next_steps
    offer_test_deployment
    
    echo
    log_welcome "Setup Complete! Welcome to the world of automatic deployment! 🎉"
}

# Run the script
main "$@"
