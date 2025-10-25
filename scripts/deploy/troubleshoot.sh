#!/bin/bash

# CI/CD Conflict Management Script
# Used to detect and handle conflicts with existing CI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Check GitHub CLI
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not installed"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        log_error "Please login to GitHub CLI first: gh auth login"
        exit 1
    fi
}

# Get currently running workflows
get_running_workflows() {
    local commit_sha=$1
    
    log_info "Checking running workflows for commit $commit_sha..."
    
    # Get all running workflows
    gh run list \
        --json databaseId,workflowName,status,headSha,url \
        --jq ".[] | select(.status == \"in_progress\" or .status == \"queued\")" \
        > /tmp/running_workflows.json
    
    # Filter workflows for the same commit
    jq --arg sha "$commit_sha" \
        '.[] | select(.headSha == $sha)' \
        /tmp/running_workflows.json > /tmp/conflicting_workflows.json || echo "[]" > /tmp/conflicting_workflows.json
}

# Detect CI/CD conflicts
detect_conflicts() {
    local commit_sha=${1:-$(git rev-parse HEAD)}
    
    log_info "Detecting CI/CD conflicts..."
    
    get_running_workflows "$commit_sha"
    
    local conflicts=$(jq length /tmp/conflicting_workflows.json)
    
    if [[ $conflicts -eq 0 ]]; then
        log_success "No conflicting workflows detected"
        return 0
    fi
    
    log_warning "Detected $conflicts conflicting workflows:"
    
    jq -r '.[] | "  - \(.workflowName) (ID: \(.databaseId)) - \(.url)"' /tmp/conflicting_workflows.json
    
    return 1
}

# Cancel conflicting CI workflows
cancel_conflicting_ci() {
    local commit_sha=${1:-$(git rev-parse HEAD)}
    local force=${2:-false}
    
    log_info "Cancelling conflicting CI workflows..."
    
    get_running_workflows "$commit_sha"
    
    # Filter CI workflows (excluding auto-cicd)
    jq '.[] | select(.workflowName == "Continuous Integration")' \
        /tmp/conflicting_workflows.json > /tmp/ci_workflows.json || echo "[]" > /tmp/ci_workflows.json
    
    local ci_count=$(jq length /tmp/ci_workflows.json)
    
    if [[ $ci_count -eq 0 ]]; then
        log_info "No conflicting CI workflows to cancel"
        return 0
    fi
    
    if [[ "$force" != "true" ]]; then
        log_warning "Found $ci_count conflicting CI workflows:"
        jq -r '.[] | "  - \(.workflowName) (ID: \(.databaseId))"' /tmp/ci_workflows.json
        
        echo -n "Cancel these workflows? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Operation cancelled"
            return 1
        fi
    fi
    
    # Cancel CI workflows
    local cancelled=0
    while read -r workflow_id; do
        if [[ -n "$workflow_id" ]]; then
            log_info "Cancelling workflow ID: $workflow_id"
            if gh run cancel "$workflow_id"; then
                ((cancelled++))
            else
                log_warning "Failed to cancel workflow $workflow_id"
            fi
        fi
    done < <(jq -r '.[].databaseId' /tmp/ci_workflows.json)
    
    log_success "Successfully cancelled $cancelled CI workflows"
}

# Wait for conflicts to be resolved
wait_for_conflicts_resolved() {
    local commit_sha=${1:-$(git rev-parse HEAD)}
    local max_wait=${2:-300}  # Maximum wait time (seconds)
    local check_interval=10   # Check interval (seconds)
    
    log_info "Waiting for conflicts to be resolved (max wait time: ${max_wait}s)..."
    
    local elapsed=0
    while [[ $elapsed -lt $max_wait ]]; do
        if detect_conflicts "$commit_sha" &>/dev/null; then
            log_success "All conflicts resolved"
            return 0
        fi
        
        local remaining=$((max_wait - elapsed))
        log_info "Conflicts still exist, waiting... (remaining time: ${remaining}s)"
        
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
    done
    
    log_warning "Wait timeout, conflicts still unresolved"
    return 1
}

# Smart conflict resolution
smart_conflict_resolution() {
    local commit_sha=${1:-$(git rev-parse HEAD)}
    local strategy=${2:-"cancel_ci"}  # cancel_ci, wait, interactive
    
    log_info "Smart conflict resolution strategy: $strategy"
    
    case "$strategy" in
        "cancel_ci")
            # Automatically cancel CI workflows
            cancel_conflicting_ci "$commit_sha" true
            ;;
        "wait")
            # Wait for conflicts to resolve naturally
            wait_for_conflicts_resolved "$commit_sha"
            ;;
        "interactive")
            # Interactive handling
            if ! detect_conflicts "$commit_sha"; then
                echo
                echo "Conflict resolution options:"
                echo "1) Cancel conflicting CI workflows"
                echo "2) Wait for conflicts to resolve naturally"
                echo "3) Handle manually"
                echo "4) Exit"
                
                while true; do
                    echo -n "Please choose (1-4): "
                    read -r choice
                    case $choice in
                        1)
                            cancel_conflicting_ci "$commit_sha"
                            break
                            ;;
                        2)
                            wait_for_conflicts_resolved "$commit_sha"
                            break
                            ;;
                        3)
                            log_info "Please handle conflicts manually and run again"
                            return 1
                            ;;
                        4)
                            log_info "Exiting conflict resolution"
                            return 1
                            ;;
                        *)
                            echo "Invalid choice, please try again"
                            ;;
                    esac
                done
            fi
            ;;
        *)
            log_error "Unknown conflict resolution strategy: $strategy"
            return 1
            ;;
    esac
}

# Monitor workflow status
monitor_workflow_status() {
    local workflow_name=${1:-"Auto CI/CD Pipeline"}
    local max_duration=${2:-1800}  # 30 minutes
    local check_interval=30
    
    log_info "Monitoring workflow status: $workflow_name"
    
    local start_time=$(date +%s)
    local elapsed=0
    
    while [[ $elapsed -lt $max_duration ]]; do
        # Get latest workflow run
        local latest_run=$(gh run list --workflow="$workflow_name" --limit=1 --json status,conclusion,url)
        
        if [[ $(echo "$latest_run" | jq length) -eq 0 ]]; then
            log_info "No workflow run found"
            sleep $check_interval
            continue
        fi
        
        local status=$(echo "$latest_run" | jq -r '.[0].status')
        local conclusion=$(echo "$latest_run" | jq -r '.[0].conclusion')
        local url=$(echo "$latest_run" | jq -r '.[0].url')
        
        case "$status" in
            "completed")
                case "$conclusion" in
                    "success")
                        log_success "Workflow executed successfully! 🎉"
                        log_info "Details: $url"
                        return 0
                        ;;
                    "failure")
                        log_error "Workflow execution failed! ❌"
                        log_info "Details: $url"
                        return 1
                        ;;
                    "cancelled")
                        log_warning "Workflow was cancelled! ⏹️"
                        log_info "Details: $url"
                        return 1
                        ;;
                    *)
                        log_warning "Workflow completed with status: $conclusion"
                        log_info "Details: $url"
                        return 1
                        ;;
                esac
                ;;
            "in_progress"|"queued")
                local current_time=$(date +%s)
                elapsed=$((current_time - start_time))
                local remaining=$((max_duration - elapsed))
                
                log_info "Workflow running... (status: $status, remaining time: ${remaining}s)"
                ;;
            *)
                log_warning "Unknown workflow status: $status"
                ;;
        esac
        
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
    done
    
    log_warning "Monitoring timeout, workflow may still be running"
    return 1
}

# Generate conflict report
generate_conflict_report() {
    local output_file=${1:-"/tmp/conflict_report.json"}
    
    log_info "Generating conflict report..."
    
    # Get status of all workflows
    gh run list --limit=50 --json databaseId,workflowName,status,conclusion,startedAt,headSha,headBranch,url > /tmp/all_workflows.json
    
    # Analyze conflict patterns
    local report=$(cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "analysis": {
    "total_runs": $(jq length /tmp/all_workflows.json),
    "by_status": $(jq 'group_by(.status) | map({status: .[0].status, count: length})' /tmp/all_workflows.json),
    "by_workflow": $(jq 'group_by(.workflowName) | map({workflow: .[0].workflowName, count: length})' /tmp/all_workflows.json),
    "recent_conflicts": $(jq '[.[] | select(.status == "in_progress" or .status == "queued")] | group_by(.headSha) | map(select(length > 1)) | map({commit: .[0].headSha, workflows: [.[].workflowName]})' /tmp/all_workflows.json)
  },
  "recommendations": [
    "Use special branch prefixes to avoid triggering regular CI",
    "Use clear trigger keywords in commit messages",
    "Configure workflow concurrency control",
    "Use repository_dispatch events for API triggers"
  ]
}
EOF
)
    
        echo "$report" | jq . > "$output_file"
        log_success "Conflict report generated: $output_file"
}

interactive_menu() {
    while true; do
        echo
        echo "=========== Conflict Management ==========="
        echo "1) Detect conflicts for current commit"
        echo "2) Cancel conflicting CI workflows"
        echo "3) Wait until conflicts are resolved"
        echo "4) Smart resolve (interactive)"
        echo "5) Monitor workflow status"
        echo "6) Generate conflict report"
        echo "0) Exit"
        echo "=========================================="
        echo -n "Choose an option: "
        read -r choice
        
        case "$choice" in
            1)
                detect_conflicts
                ;;
            2)
                cancel_conflicting_ci
                ;;
            3)
                wait_for_conflicts_resolved
                ;;
            4)
                smart_conflict_resolution "$(git rev-parse HEAD 2>/dev/null || echo HEAD)" "interactive"
                ;;
            5)
                monitor_workflow_status "Auto CI/CD Pipeline"
                ;;
            6)
                generate_conflict_report
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

# Main function
main() {
    local command=${1:-"help"}
    local commit_sha=${2:-$(git rev-parse HEAD 2>/dev/null || echo "")}
    
    check_gh_cli
    
    case "$command" in
        "interactive")
            interactive_menu
            ;;
        "detect")
            detect_conflicts "$commit_sha"
            ;;
        "cancel")
            cancel_conflicting_ci "$commit_sha"
            ;;
        "wait")
            wait_for_conflicts_resolved "$commit_sha"
            ;;
        "resolve")
            local strategy=${3:-"interactive"}
            smart_conflict_resolution "$commit_sha" "$strategy"
            ;;
        "monitor")
            local workflow=${3:-"Auto CI/CD Pipeline"}
            monitor_workflow_status "$workflow"
            ;;
        "report")
            local output=${3:-"/tmp/conflict_report.json"}
            generate_conflict_report "$output"
            ;;
        "help"|*)
            cat << EOF
🔧 CI/CD Conflict Management Script

Usage: $0 <command> [parameters]

Commands:
  interactive                Guided conflict management
  detect [commit_sha]           Detect conflicting workflows
  cancel [commit_sha]           Cancel conflicting CI workflows
  wait [commit_sha]             Wait for conflicts to resolve
  resolve [commit_sha] [strategy] Smart conflict resolution
  monitor [workflow_name]       Monitor workflow status
  report [output_file]          Generate conflict report
  help                          Show this help

Strategy options (resolve command):
  cancel_ci    Automatically cancel CI workflows
  wait         Wait for conflicts to resolve naturally
  interactive  Interactive handling

Examples:
  $0 detect                     # Detect conflicts for current commit
  $0 cancel abc123              # Cancel CI workflows for specified commit
  $0 resolve HEAD interactive   # Interactive conflict resolution
  $0 monitor "Auto CI/CD"       # Monitor auto CI/CD workflow

EOF
            ;;
    esac
}

# Cleanup temporary files
cleanup() {
    rm -f /tmp/running_workflows.json /tmp/conflicting_workflows.json /tmp/ci_workflows.json /tmp/all_workflows.json
}

trap cleanup EXIT

# Run main function
main "$@"
