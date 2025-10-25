#!/bin/bash

# EasyDeploy Demo Script 🎮
# See how easy deployment can be!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Fun and friendly colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Enhanced logging functions with emojis
log_title() { echo -e "\n${PURPLE}🎯 $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${CYAN}📋 $1${NC}"; }

# Demo functions with beginner-friendly explanations
demo_commit_trigger() {
    log_title "Demo 1: Deploy with Magic Words in Your Commits!"
    
    echo "✨ EasyDeploy watches for special words in your commit messages."
    echo "Just add these magic words and your app deploys automatically!"
    echo
    echo "💡 Examples of what you can do:"
    echo
    echo "1. 🚀 Deploy to testing environment:"
    echo "   git commit -m '[deploy] Fixed the login bug - ready to test!'"
    echo
    echo "2. Deploy to production:"
    echo "   git commit -m '[auto-deploy] [production] Release v1.2.0'"
    echo
    echo "3. Skip tests for quick deployment:"
    echo "   git commit -m '[auto-deploy] [skip-tests] Emergency hotfix'"
    echo
    echo "4. Force deploy to production:"
    echo "   git commit -m '[auto-deploy] [production] [force] Force release important update'"
    
    echo
    echo -n "Would you like to simulate a commit trigger? (y/N): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Simulating: git commit -m '[auto-deploy] Demo deployment'"
        log_success "This would trigger auto CI/CD to staging environment"
    fi
}

demo_branch_trigger() {
    log_title "Demo 2: Trigger via Special Branch"
    
    echo "Supported branch prefixes:"
    echo
    echo "1. auto-deploy/*    -> Deploy to staging"
    echo "2. release-candidate/* -> Deploy to production"
    echo "3. hotfix/*         -> Hotfix deployment"
    echo
    echo "Examples:"
    echo "  git checkout -b auto-deploy/feature-x"
    echo "  git push origin auto-deploy/feature-x"
    
    echo
    echo -n "Would you like to check current branch status? (y/N): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "All branches:"
        git branch -a 2>/dev/null | head -10 || echo "Cannot get branch information"
    fi
}

demo_script_usage() {
    log_title "Demo 3: Using Trigger Scripts"
    
    echo "The trigger script provides a convenient command-line interface:"
    echo
    echo "Basic usage:"
    echo "  ./scripts/deploy/auto-deploy.sh commit-trigger        # Trigger via commit"
    echo "  ./scripts/deploy/auto-deploy.sh branch-trigger        # Trigger via branch"
    echo "  ./scripts/deploy/auto-deploy.sh api-trigger           # Trigger via API"
    echo "  ./scripts/deploy/auto-deploy.sh status                # Check status"
    echo
    echo "Usage with parameters:"
    echo "  ./scripts/deploy/auto-deploy.sh commit-trigger -e production  # Deploy to production"
    echo "  ./scripts/deploy/auto-deploy.sh branch-trigger -s             # Skip tests"
    echo "  ./scripts/deploy/auto-deploy.sh api-trigger -f                # Force deploy"
    
    echo
    echo -n "Would you like to see trigger script help? (y/N): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if [[ -f "./scripts/deploy/auto-deploy.sh" ]]; then
            ./scripts/deploy/auto-deploy.sh --help
        else
            log_warning "Trigger script does not exist, please check file location"
        fi
    fi
}

demo_api_trigger() {
    log_title "Demo 4: Trigger via API"
    
    echo "API triggers support three event types:"
    echo
    echo "1. auto-cicd        -> General auto deployment"
    echo "2. deploy-staging   -> Deploy to staging"
    echo "3. deploy-production -> Deploy to production"
    echo
    echo "curl example:"
    cat << 'EOF'
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
EOF
    
    echo
    echo "GitHub CLI example:"
    echo 'gh api repos/:owner/:repo/dispatches \'
    echo '  --method POST \'
    echo '  --field event_type="deploy-staging"'
}

demo_conflict_management() {
    log_title "Demo 5: Conflict Management"
    
    echo "Conflict management script features:"
    echo
    echo "1. detect    -> Detect conflicting workflows"
    echo "2. cancel    -> Cancel conflicting CI workflows"
    echo "3. resolve   -> Smart conflict resolution"
    echo "4. monitor   -> Monitor workflow status"
    echo "5. report    -> Generate conflict report"
    echo
    echo "Example usage:"
    echo "  ./scripts/deploy/troubleshoot.sh detect"
    echo "  ./scripts/deploy/troubleshoot.sh resolve HEAD interactive"
    echo "  ./scripts/deploy/troubleshoot.sh monitor 'Auto CI/CD Pipeline'"
    
    echo
    echo -n "Would you like to see conflict management script help? (y/N): "
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if [[ -f "./scripts/deploy/troubleshoot.sh" ]]; then
            ./scripts/deploy/troubleshoot.sh help
        else
            log_warning "Conflict management script does not exist, please check file location"
        fi
    fi
}

show_system_overview() {
    log_title "Auto CI/CD System Overview"
    
    echo "🏗️  System Architecture:"
    echo "  ├── GitHub Actions Workflows"
    echo "  │   ├── auto-cicd.yml (Main auto CI/CD)"
    echo "  │   ├── ci.yml (Existing CI, unchanged)"
    echo "  │   └── cd.yml (Existing CD, unchanged)"
    echo "  ├── Trigger Scripts"
    echo "  │   ├── trigger.sh (Main trigger tool)"
    echo "  │   └── conflict_manager.sh (Conflict management)"
    echo "  ├── Configuration Files"
    echo "  │   └── auto_cicd_config.json"
    echo "  └── Documentation"
    echo "      └── AUTO_CICD_GUIDE.md"
    echo
    echo "🎯 Key Features:"
    echo "  ✅ Multiple trigger methods (commit, branch, API, manual)"
    echo "  ✅ Smart conflict avoidance"
    echo "  ✅ Environment isolation (staging/production)"
    echo "  ✅ Flexible control options"
    echo "  ✅ Real-time status monitoring"
    echo "  ✅ Detailed logging"
    echo
    echo "🔄 Workflow Process:"
    echo "  1. Trigger detection"
    echo "  2. Conflict handling"
    echo "  3. Quick CI check"
    echo "  4. Build artifacts"
    echo "  5. Environment deployment"
    echo "  6. Result notification"
}

check_system_status() {
    log_title "System Status Check"
    
    # Check file existence
    echo "📁 File Check:"
    local files=(
        ".github/workflows/auto-cicd.yml"
        "scripts/deploy/auto-deploy.sh"
        "scripts/deploy/troubleshoot.sh"
        "config/auto_cicd_config.json"
        "docs/AUTO_CICD_GUIDE.md"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "$file"
        else
            log_error "$file (missing)"
        fi
    done
    
    echo
    echo "🔧 Dependency Check:"
    
    # Check Git
    if command -v git &> /dev/null; then
        log_success "Git: $(git --version)"
    else
        log_error "Git not installed"
    fi
    
    # Check GitHub CLI
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI: $(gh --version | head -1)"
        if gh auth status &> /dev/null; then
            log_success "GitHub CLI authenticated"
        else
            log_warning "GitHub CLI not authenticated"
        fi
    else
        log_warning "GitHub CLI not installed (optional)"
    fi
    
    # Check jq
    if command -v jq &> /dev/null; then
        log_success "jq: $(jq --version)"
    else
        log_warning "jq not installed (used for JSON processing)"
    fi
}

interactive_demo() {
    while true; do
        echo
        echo "🎭 Auto CI/CD System Demo"
        echo "========================="
        echo "0) System Overview"
        echo "1) Commit Message Trigger"
        echo "2) Special Branch Trigger"
        echo "3) Script Tool Usage"
        echo "4) API Trigger"
        echo "5) Conflict Management"
        echo "6) System Status Check"
        echo "7) View Complete Documentation"
        echo "q) Exit"
        echo
        echo -n "Please select demo content (0-7, q): "
        read -r choice
        
        case $choice in
            0) show_system_overview ;;
            1) demo_commit_trigger ;;
            2) demo_branch_trigger ;;
            3) demo_script_usage ;;
            4) demo_api_trigger ;;
            5) demo_conflict_management ;;
            6) check_system_status ;;
            7) 
                if [[ -f "docs/AUTO_CICD_GUIDE.md" ]]; then
                    echo "Displaying complete documentation..."
                    echo "=================================="
                    cat docs/AUTO_CICD_GUIDE.md | head -50
                    echo
                    echo "... (Documentation is lengthy, see complete content in docs/AUTO_CICD_GUIDE.md)"
                else
                    log_error "Documentation file does not exist"
                fi
                ;;
            q|Q) 
                log_success "Thank you for using the Auto CI/CD System!"
                exit 0
                ;;
            *) 
                log_warning "Invalid selection, please try again"
                ;;
        esac
        
        echo
        echo -n "Press Enter to continue..."
        read -r
    done
}

# Main function
main() {
    local mode=${1:-"interactive"}
    
    case $mode in
        "overview")
            show_system_overview
            ;;
        "status")
            check_system_status
            ;;
        "all")
            show_system_overview
            demo_commit_trigger
            demo_branch_trigger
            demo_script_usage
            demo_api_trigger
            demo_conflict_management
            check_system_status
            ;;
        "interactive"|*)
            interactive_demo
            ;;
    esac
}

echo "🚀 Auto CI/CD System Demo Starting..."
echo "Goal: Provide intelligent and efficient CI/CD automation solutions"
echo "Features: Avoid conflicts with existing CI, support multiple trigger methods"

main "$@"
