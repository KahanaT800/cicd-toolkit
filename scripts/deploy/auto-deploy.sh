#!/bin/bash

# EasyDeploy Trigger Script 🚀
# Deploy your apps effortlessly with multiple trigger options!
# No DevOps experience required!

set -euo pipefail

# Friendly colors for better user experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Beginner-friendly defaults
DEFAULT_ENVIRONMENT="staging"
DEFAULT_SKIP_TESTS=false
DEFAULT_FORCE_DEPLOY=false
CUSTOM_MESSAGE=""

# Show beginner-friendly help
show_help() {
    cat << EOF
🚀 EasyDeploy Trigger Script
Deploy your apps effortlessly - No DevOps experience required!

Usage: $0 [options] [command]

Commands:
  interactive       Guided deployment menu
  commit-trigger    Trigger via special commit message
  branch-trigger    Create special branch to trigger
  api-trigger       Trigger via GitHub API
  manual-trigger    Trigger via GitHub Actions manual trigger
  webhook-trigger   Setup webhook trigger
  status            Check current CI/CD status

Options:
  -e, --environment ENV     Deployment environment (staging|production) [default: staging]
  -s, --skip-tests         Skip tests and deploy directly
  -f, --force              Force deployment (even if tests fail)
  -m, --message MSG        Custom commit message details
  -h, --help               Show this help information

Examples:
  $0 commit-trigger -e production          # Trigger production deployment via commit message
  $0 branch-trigger -s                     # Create branch trigger, skip tests
  $0 api-trigger -e staging -f             # API trigger, force deploy to staging
  $0 status                                # Check status

Trigger Methods:
  1. Commit Message: Include [deploy] or [auto-deploy] in commit message
  2. Special Branch: Push to auto-deploy/* or release-candidate/* branches
  3. API Trigger: Via GitHub repository_dispatch events
  4. Manual Trigger: Via GitHub Actions interface

EOF
}

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check GitHub CLI
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not installed, please install: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        log_error "Please login to GitHub CLI first: gh auth login"
        exit 1
    fi
}

# Check repository information
check_repo_info() {
    # Check if current directory is a Git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "Current directory is not a Git repository"
        echo
        echo -e "🔧 ${YELLOW}How to fix this:${NC}"
        echo -e "  1. Navigate to your project directory: ${BLUE}cd /path/to/your/project${NC}"
        echo -e "  2. Initialize Git repository: ${BLUE}git init${NC}"
        echo -e "  3. Add your files: ${BLUE}git add .${NC}"
        echo -e "  4. Make initial commit: ${BLUE}git commit -m \"Initial commit\"${NC}"
        echo "  5. Create GitHub repository and add remote:"
        echo -e "     ${BLUE}gh repo create your-repo-name --public${NC}"
        echo -e "     ${BLUE}git remote add origin https://github.com/username/your-repo-name.git${NC}"
        echo -e "  6. Push to GitHub: ${BLUE}git push -u origin main${NC}"
        echo
        exit 1
    fi
    
    # Check if Git remotes exist
    if ! git remote | grep -q .; then
        log_error "No Git remotes found - this repository is not connected to GitHub"
        echo
        echo -e "🔧 ${YELLOW}How to fix this:${NC}"
        echo "  1. Create a GitHub repository:"
        echo -e "     ${BLUE}gh repo create your-repo-name --public${NC}"
        echo "  2. Add remote origin:"
        echo -e "     ${BLUE}git remote add origin https://github.com/username/your-repo-name.git${NC}"
        echo "  3. Push your code:"
        echo -e "     ${BLUE}git push -u origin main${NC}"
        echo
        echo -e "  💡 ${CYAN}Or connect to existing repository:${NC}"
        echo -e "     ${BLUE}git remote add origin https://github.com/username/existing-repo.git${NC}"
        echo
        exit 1
    fi
    
    # Check if GitHub repository exists and is accessible
    if ! REPO_INFO=$(gh repo view --json nameWithOwner,defaultBranchRef -q '{owner: .nameWithOwner, branch: .defaultBranchRef.name}' 2>/dev/null); then
        log_error "Cannot access GitHub repository or repository doesn't exist"
        echo
        echo -e "🔧 ${YELLOW}Possible solutions:${NC}"
        echo -e "  1. ${BLUE}Check GitHub CLI authentication:${NC}"
        echo -e "     ${BLUE}gh auth status${NC}"
        echo -e "     ${BLUE}gh auth login${NC} (if not authenticated)"
        echo
        echo -e "  2. ${BLUE}Verify repository exists and you have access:${NC}"
        echo -e "     ${BLUE}gh repo view${NC}"
        echo
        echo -e "  3. ${BLUE}Create repository if it doesn't exist:${NC}"
        echo -e "     ${BLUE}gh repo create --public${NC}"
        echo
        echo -e "  4. ${BLUE}Check remote URL is correct:${NC}"
        echo -e "     ${BLUE}git remote -v${NC}"
        echo
        exit 1
    fi
    
    REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.owner')
    DEFAULT_BRANCH=$(echo "$REPO_INFO" | jq -r '.branch')
    
    if [[ "$REPO_OWNER" == "null" || "$DEFAULT_BRANCH" == "null" ]]; then
        log_error "Unable to retrieve repository information"
        echo
        echo -e "🔧 ${YELLOW}How to fix this:${NC}"
        echo "  1. Ensure you're in the correct repository directory"
        echo -e "  2. Check repository permissions: ${BLUE}gh repo view${NC}"
        echo -e "  3. Verify GitHub CLI has proper scopes: ${BLUE}gh auth refresh -s repo,workflow${NC}"
        echo
        exit 1
    fi
    
    log_info "Repository: $REPO_OWNER"
    log_info "Default branch: $DEFAULT_BRANCH"
}

# Trigger via commit message
commit_trigger() {
    local environment=$1
    local skip_tests=$2
    local force_deploy=$3
    local provided_message=${4:-$CUSTOM_MESSAGE}
    
    log_info "Preparing to trigger auto CI/CD via commit message..."
    
    # Build commit message
    local commit_msg="[auto-deploy]"
    
    if [[ "$environment" == "production" ]]; then
        commit_msg="$commit_msg [production]"
    fi
    
    if [[ "$skip_tests" == "true" ]]; then
        commit_msg="$commit_msg [skip-tests]"
    fi
    
    if [[ "$force_deploy" == "true" ]]; then
        commit_msg="$commit_msg [force]"
    fi
    
    if [[ -z "$provided_message" ]]; then
        if [[ -t 0 ]]; then
            echo -n "Please enter commit message (trigger tags will be auto-added): "
            read -r provided_message
        fi
    fi
    
    if [[ -n "$provided_message" ]]; then
        commit_msg="$commit_msg $provided_message"
    else
        commit_msg="$commit_msg Trigger auto deployment"
    fi
    
    # Check for staged changes
    if git diff --staged --quiet && git diff --quiet; then
        log_warning "No changes to commit, creating empty commit..."
        git commit --allow-empty -m "$commit_msg"
    else
        git add .
        git commit -m "$commit_msg"
    fi
    
    log_success "Commit created: $commit_msg"
    
    # Push to remote
    log_info "Pushing to remote repository..."
    git push origin HEAD
    
    log_success "🚀 Auto CI/CD triggered via commit message!"
    log_info "Environment: $environment"
    log_info "Skip tests: $skip_tests"
    log_info "Force deploy: $force_deploy"
}

# Trigger via special branch
branch_trigger() {
    local environment=$1
    local skip_tests=$2
    local force_deploy=$3
    
    log_info "Preparing to trigger auto CI/CD via special branch..."
    
    # Determine branch prefix
    local branch_prefix
    if [[ "$environment" == "production" ]]; then
        branch_prefix="release-candidate"
    else
        branch_prefix="auto-deploy"
    fi
    
    # Generate branch name
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local branch_name="${branch_prefix}/${timestamp}"
    
    log_info "Creating branch: $branch_name"
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    
    # If no changes, create a marker file
    if git diff --staged --quiet && git diff --quiet; then
        echo "Auto deployment triggered at $(date)" > ".auto-deploy-trigger"
        git add ".auto-deploy-trigger"
        git commit -m "Trigger auto deployment via branch"
    fi
    
    # Push branch
    log_info "Pushing branch to remote..."
    git push origin "$branch_name"
    
    log_success "🚀 Auto CI/CD triggered via branch!"
    log_info "Branch: $branch_name"
    log_info "Environment: $environment"
    
    # Switch back to original branch
    git checkout -
    
    # Ask if local branch should be deleted
    echo -n "Delete local temporary branch? (y/N): "
    read -r delete_branch
    if [[ "$delete_branch" =~ ^[Yy]$ ]]; then
        git branch -D "$branch_name"
        log_success "Local branch deleted"
    fi
}

# Trigger via API
api_trigger() {
    local environment=$1
    local skip_tests=$2
    local force_deploy=$3
    
    log_info "Preparing to trigger auto CI/CD via GitHub API..."
    
    # Build payload
    local event_type="auto-cicd"
    local payload="{
        \"environment\": \"$environment\",
        \"skip_tests\": $skip_tests,
        \"force_deploy\": $force_deploy,
        \"triggered_by\": \"$(git config user.name || echo 'unknown')\",
        \"timestamp\": \"$(date -Iseconds)\"
    }"
    
    log_info "Sending repository_dispatch event..."
    log_info "Event Type: $event_type"
    log_info "Payload: $payload"
    
    # Send API request
    if gh api repos/:owner/:repo/dispatches \
        --method POST \
        --field event_type="$event_type" \
        --field client_payload="$payload"; then
        
        log_success "🚀 Auto CI/CD triggered via API!"
        log_info "Environment: $environment"
        log_info "Skip tests: $skip_tests"
        log_info "Force deploy: $force_deploy"
    else
        log_error "API trigger failed"
        exit 1
    fi
}

# Manual trigger (open GitHub Actions page)
manual_trigger() {
    local environment=$1
    local skip_tests=$2
    local force_deploy=$3
    
    log_info "Preparing to open GitHub Actions page for manual trigger..."
    
    # Get repository URL
    local repo_url=$(gh repo view --json url -q '.url')
    local actions_url="${repo_url}/actions/workflows/auto-cicd.yml"
    
    log_info "Will open browser to: $actions_url"
    log_info "Suggested parameters:"
    log_info "  Environment: $environment"
    log_info "  Skip tests: $skip_tests"
    log_info "  Force deploy: $force_deploy"
    
    # Try to open browser
    if command -v xdg-open &> /dev/null; then
        xdg-open "$actions_url"
    elif command -v open &> /dev/null; then
        open "$actions_url"
    else
        log_warning "Cannot auto-open browser, please visit manually: $actions_url"
    fi
    
    log_success "Please manually trigger workflow on GitHub Actions page"
}

# Setup webhook trigger
webhook_trigger() {
    log_info "Setting up webhook trigger..."
    
    cat << EOF
🔗 Webhook Trigger Configuration

To trigger auto CI/CD via webhook, you can:

1. Use curl command:
   curl -X POST \\
     -H "Accept: application/vnd.github.v3+json" \\
     -H "Authorization: token YOUR_TOKEN" \\
     https://api.github.com/repos/$REPO_OWNER/dispatches \\
     -d '{
       "event_type": "auto-cicd",
       "client_payload": {
         "environment": "staging",
         "skip_tests": false,
         "force_deploy": false
       }
     }'

2. Create GitHub Personal Access Token:
   - Visit: https://github.com/settings/tokens
   - Create token with at least 'repo' permissions

3. Integrate with other systems:
   - CI/CD platforms (Jenkins, GitLab CI, etc.)
   - Monitoring systems (Prometheus AlertManager, etc.)
   - Chat bots (Slack, Teams, etc.)

4. Available event_type values:
   - auto-cicd: General auto deployment
   - deploy-staging: Deploy to staging
   - deploy-production: Deploy to production

EOF
}

# Check CI/CD status
check_status() {
    log_info "Checking current CI/CD status..."
    
    echo
    echo "📊 Recent workflow runs:"
    gh run list --workflow=auto-cicd.yml --limit=5 --json status,conclusion,startedAt,headBranch,displayTitle
    
    echo
    echo "🔄 Currently running workflows:"
    gh run list --workflow=auto-cicd.yml --status=in_progress --json status,startedAt,headBranch,displayTitle
    
    echo
    echo "📈 Overall statistics:"
    local total_runs=$(gh run list --workflow=auto-cicd.yml --json status | jq length)
    local success_runs=$(gh run list --workflow=auto-cicd.yml --json conclusion | jq '[.[] | select(.conclusion == "success")] | length')
    local failed_runs=$(gh run list --workflow=auto-cicd.yml --json conclusion | jq '[.[] | select(.conclusion == "failure")] | length')
    
    echo "  Total runs: $total_runs"
    echo "  Successful runs: $success_runs"
    echo "  Failed runs: $failed_runs"
    
    if [[ $total_runs -gt 0 ]]; then
        local success_rate=$(echo "scale=2; $success_runs * 100 / $total_runs" | bc -l 2>/dev/null || echo "N/A")
        echo "  Success rate: ${success_rate}%"
    fi
}

interactive_menu() {
    while true; do
        echo
        echo "================ EasyDeploy Interactive ================"
        echo "1) Commit message trigger"
        echo "2) Special branch trigger"
        echo "3) API trigger"
        echo "4) Manual trigger (open Actions page)"
        echo "5) Check workflow status"
        echo "0) Exit"
        echo "======================================================="
        echo -n "Choose an option: "
        read -r choice
        
        case "$choice" in
            1)
                local env="$ENVIRONMENT"
                local skip="$SKIP_TESTS"
                local force="$FORCE_DEPLOY"
                local message=""
                
                echo -n "Target environment [staging/production] (default: $env): "
                read -r env_input
                if [[ "$env_input" =~ ^(staging|production)$ ]]; then
                    env="$env_input"
                fi
                
                echo -n "Skip tests? (y/N): "
                read -r skip_answer
                if [[ "$skip_answer" =~ ^[Yy]$ ]]; then
                    skip=true
                else
                    skip=false
                fi
                
                echo -n "Force deploy? (y/N): "
                read -r force_answer
                if [[ "$force_answer" =~ ^[Yy]$ ]]; then
                    force=true
                else
                    force=false
                fi
                
                echo -n "Additional commit message (optional): "
                read -r message
                
                commit_trigger "$env" "$skip" "$force" "$message"
                ;;
            2)
                local env="$ENVIRONMENT"
                local skip="$SKIP_TESTS"
                local force="$FORCE_DEPLOY"
                
                echo -n "Target environment [staging/production] (default: $env): "
                read -r env_input
                if [[ "$env_input" =~ ^(staging|production)$ ]]; then
                    env="$env_input"
                fi
                
                echo -n "Skip tests? (y/N): "
                read -r skip_answer
                if [[ "$skip_answer" =~ ^[Yy]$ ]]; then
                    skip=true
                else
                    skip=false
                fi
                
                echo -n "Force deploy? (y/N): "
                read -r force_answer
                if [[ "$force_answer" =~ ^[Yy]$ ]]; then
                    force=true
                else
                    force=false
                fi
                
                branch_trigger "$env" "$skip" "$force"
                ;;
            3)
                local env="$ENVIRONMENT"
                local skip="$SKIP_TESTS"
                local force="$FORCE_DEPLOY"
                
                echo -n "Target environment [staging/production] (default: $env): "
                read -r env_input
                if [[ "$env_input" =~ ^(staging|production)$ ]]; then
                    env="$env_input"
                fi
                
                echo -n "Skip tests? (y/N): "
                read -r skip_answer
                if [[ "$skip_answer" =~ ^[Yy]$ ]]; then
                    skip=true
                else
                    skip=false
                fi
                
                echo -n "Force deploy? (y/N): "
                read -r force_answer
                if [[ "$force_answer" =~ ^[Yy]$ ]]; then
                    force=true
                else
                    force=false
                fi
                
                api_trigger "$env" "$skip" "$force"
                ;;
            4)
                local env="$ENVIRONMENT"
                local skip="$SKIP_TESTS"
                local force="$FORCE_DEPLOY"
                
                echo -n "Target environment [staging/production] (default: $env): "
                read -r env_input
                if [[ "$env_input" =~ ^(staging|production)$ ]]; then
                    env="$env_input"
                fi
                
                echo -n "Skip tests? (y/N): "
                read -r skip_answer
                if [[ "$skip_answer" =~ ^[Yy]$ ]]; then
                    skip=true
                else
                    skip=false
                fi
                
                echo -n "Force deploy? (y/N): "
                read -r force_answer
                if [[ "$force_answer" =~ ^[Yy]$ ]]; then
                    force=true
                else
                    force=false
                fi
                
                manual_trigger "$env" "$skip" "$force"
                ;;
            5)
                check_status
                ;;
            0)
                return 0
                ;;
            *)
                log_warning "Invalid choice, please try again."
                ;;
        esac
    done
}

# Parse command line arguments
ENVIRONMENT="$DEFAULT_ENVIRONMENT"
SKIP_TESTS="$DEFAULT_SKIP_TESTS"
FORCE_DEPLOY="$DEFAULT_FORCE_DEPLOY"
COMMAND=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -f|--force)
            FORCE_DEPLOY=true
            shift
            ;;
        -m|--message)
            CUSTOM_MESSAGE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        interactive|commit-trigger|branch-trigger|api-trigger|manual-trigger|webhook-trigger|status)
            COMMAND="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default to interactive mode when no command supplied
if [[ -z "$COMMAND" ]]; then
    COMMAND="interactive"
fi

# Validate environment parameter
if [[ "$COMMAND" != "interactive" && "$COMMAND" != "status" ]]; then
    if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
        log_error "Invalid environment: $ENVIRONMENT (must be staging or production)"
        exit 1
    fi
fi

# Check dependencies
check_gh_cli
check_repo_info

cd "$PROJECT_ROOT"

# Execute corresponding command
case "$COMMAND" in
    interactive)
        interactive_menu
        ;;
    commit-trigger)
        commit_trigger "$ENVIRONMENT" "$SKIP_TESTS" "$FORCE_DEPLOY" "$CUSTOM_MESSAGE"
        ;;
    branch-trigger)
        branch_trigger "$ENVIRONMENT" "$SKIP_TESTS" "$FORCE_DEPLOY"
        ;;
    api-trigger)
        api_trigger "$ENVIRONMENT" "$SKIP_TESTS" "$FORCE_DEPLOY"
        ;;
    manual-trigger)
        manual_trigger "$ENVIRONMENT" "$SKIP_TESTS" "$FORCE_DEPLOY"
        ;;
    webhook-trigger)
        webhook_trigger
        ;;
    status)
        check_status
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
