#!/bin/bash

# Environment Setup Script for Auto CI/CD System
# This script helps configure the required dependencies and authentication

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_title() { echo -e "\n${CYAN}🎯 $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check system requirements
check_system() {
    log_title "System Requirements Check"
    
    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_success "Operating System: Linux"
        
        # Check distribution
        if command -v lsb_release &> /dev/null; then
            DISTRO=$(lsb_release -si)
            VERSION=$(lsb_release -sr)
            log_info "Distribution: $DISTRO $VERSION"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log_success "Operating System: macOS"
    else
        log_warning "Operating System: $OSTYPE (may not be fully supported)"
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    log_info "Architecture: $ARCH"
}

# Install jq (JSON processor)
install_jq() {
    log_title "Installing jq (JSON Processor)"
    
    if command -v jq &> /dev/null; then
        log_success "jq is already installed: $(jq --version)"
        return 0
    fi
    
    log_info "Installing jq..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y jq
        elif command -v pacman &> /dev/null; then
            sudo pacman -S jq
        else
            log_error "Package manager not supported. Please install jq manually."
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install jq
        else
            log_error "Homebrew not found. Please install jq manually."
            return 1
        fi
    fi
    
    if command -v jq &> /dev/null; then
        log_success "jq installed successfully: $(jq --version)"
    else
        log_error "Failed to install jq"
        return 1
    fi
}

# Install GitHub CLI
install_github_cli() {
    log_title "Installing GitHub CLI"
    
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI is already installed: $(gh --version | head -1)"
        return 0
    fi
    
    log_info "Installing GitHub CLI..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Add GitHub CLI repository
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        
        # Install
        sudo apt update && sudo apt install -y gh
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install gh
        else
            log_error "Homebrew not found. Please install GitHub CLI manually."
            return 1
        fi
    fi
    
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI installed successfully: $(gh --version | head -1)"
    else
        log_error "Failed to install GitHub CLI"
        return 1
    fi
}

# Configure GitHub CLI authentication
configure_github_auth() {
    log_title "GitHub CLI Authentication"
    
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI is already authenticated"
        gh auth status
        return 0
    fi
    
    log_info "GitHub CLI needs authentication to work properly"
    echo
    echo "Authentication options:"
    echo "1. Browser authentication (recommended)"
    echo "2. Token authentication"
    echo "3. Skip authentication (limited functionality)"
    echo
    
    while true; do
        echo -n "Choose authentication method (1-3): "
        read -r choice
        
        case $choice in
            1)
                log_info "Starting browser authentication..."
                gh auth login --web
                break
                ;;
            2)
                log_info "Token authentication selected"
                echo "Please create a Personal Access Token at: https://github.com/settings/tokens"
                echo "Required scopes: repo, workflow, read:org"
                echo
                echo -n "Enter your token: "
                read -rs token
                echo
                echo "$token" | gh auth login --with-token
                break
                ;;
            3)
                log_warning "Skipping authentication. Some features will not work."
                return 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    
    # Verify authentication
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI authentication successful!"
        gh auth status
    else
        log_warning "Authentication may not be complete. You can run 'gh auth login' later."
    fi
}

# Check Git configuration
check_git_config() {
    log_title "Git Configuration Check"
    
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        return 1
    fi
    
    log_success "Git is installed: $(git --version)"
    
    # Check Git user configuration
    if git config user.name &> /dev/null && git config user.email &> /dev/null; then
        log_success "Git user configuration:"
        log_info "  Name: $(git config user.name)"
        log_info "  Email: $(git config user.email)"
    else
        log_warning "Git user configuration is incomplete"
        echo
        echo -n "Would you like to configure Git user settings? (y/N): "
        read -r configure_git
        
        if [[ "$configure_git" =~ ^[Yy]$ ]]; then
            echo -n "Enter your name: "
            read -r git_name
            echo -n "Enter your email: "
            read -r git_email
            
            git config --global user.name "$git_name"
            git config --global user.email "$git_email"
            
            log_success "Git user configuration updated"
        fi
    fi
}

# Install additional dependencies
install_additional_deps() {
    log_title "Additional Dependencies"
    
    # Check for bc (basic calculator) - used in some scripts
    if ! command -v bc &> /dev/null; then
        log_info "Installing bc (basic calculator)..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt &> /dev/null; then
                sudo apt install -y bc
            elif command -v yum &> /dev/null; then
                sudo yum install -y bc
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y bc
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                brew install bc
            fi
        fi
        
        if command -v bc &> /dev/null; then
            log_success "bc installed successfully"
        fi
    else
        log_success "bc is already installed"
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        log_warning "curl is not installed. Some features may not work."
        log_info "Please install curl manually"
    else
        log_success "curl is available"
    fi
}

# Test the CI/CD system
test_system() {
    log_title "Testing Auto CI/CD System"
    
    # Check if we're in a Git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        log_warning "Not in a Git repository. Skipping repository-specific tests."
        return 0
    fi
    
    # Run system status check
    if [[ -f "./scripts/deploy/status.sh" ]]; then
        log_info "Running system status check..."
        ./scripts/deploy/status.sh status
    else
        log_warning "Auto CI/CD scripts not found in current directory"
    fi
}

# Show completion summary
show_summary() {
    log_title "Environment Setup Complete!"
    
    echo "✅ Dependencies installed:"
    
    # Check each dependency
    if command -v git &> /dev/null; then
        echo "  ✅ Git: $(git --version)"
    fi
    
    if command -v jq &> /dev/null; then
        echo "  ✅ jq: $(jq --version)"
    fi
    
    if command -v gh &> /dev/null; then
        echo "  ✅ GitHub CLI: $(gh --version | head -1)"
        if gh auth status &> /dev/null; then
            echo "    ✅ Authenticated"
        else
            echo "    ⚠️  Not authenticated"
        fi
    fi
    
    if command -v bc &> /dev/null; then
        echo "  ✅ bc: Available"
    fi
    
    echo
    echo "🎉 Your environment is now ready for the Auto CI/CD system!"
    echo
    echo "Next steps:"
    echo "1. Navigate to your project directory"
    echo "2. Run: ./scripts/deploy/status.sh interactive"
    echo "3. Try: ./scripts/deploy/auto-deploy.sh --help"
    echo
    echo "If GitHub CLI is not authenticated, run: gh auth login"
}

# Main function
main() {
    local mode=${1:-"full"}
    
    echo "🚀 Auto CI/CD Environment Setup"
    echo "==============================="
    
    check_root
    
    case $mode in
        "deps"|"dependencies")
            check_system
            install_jq
            install_github_cli
            install_additional_deps
            ;;
        "auth"|"authentication")
            configure_github_auth
            ;;
        "git")
            check_git_config
            ;;
        "test")
            test_system
            ;;
        "full"|*)
            check_system
            install_jq
            install_github_cli
            configure_github_auth
            check_git_config
            install_additional_deps
            test_system
            show_summary
            ;;
    esac
}

# Handle script arguments
if [[ $# -eq 0 ]]; then
    main
else
    case $1 in
        -h|--help)
            cat << EOF
🚀 Auto CI/CD Environment Setup Script

Usage: $0 [mode]

Modes:
  full (default)    Complete environment setup
  deps             Install dependencies only
  auth             Configure GitHub authentication only
  git              Check/configure Git settings only
  test             Test the CI/CD system
  -h, --help       Show this help

Examples:
  $0               # Full setup
  $0 deps          # Install dependencies only
  $0 auth          # Configure GitHub CLI authentication
  $0 test          # Test the system

EOF
            ;;
        *)
            main "$1"
            ;;
    esac
fi
