#!/bin/bash

# EasyDeploy Installation Script
# Deploy your apps effortlessly - No DevOps experience required!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALL_TARGET_DIR="$(pwd)"

# Save the original working directory before we start

# Colors for friendly output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Emoji-enhanced logging functions
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

log_title() {
    echo -e "\n${PURPLE}🚀 === $1 ===${NC}"
}

log_step() {
    echo -e "${BLUE}📋 Step: $1${NC}"
}

# Default values
INSTALL_DIR=""
PROJECT_TYPE="auto"
ENVIRONMENT="development"
SKIP_DEPS=false
VERBOSE=false

# Show beginner-friendly help
show_help() {
    cat << EOF
🚀 EasyDeploy Installation Script
Deploy your apps effortlessly - No DevOps experience required!

Usage: $0 [OPTIONS]

Options:
    -d, --dir DIR           📁 Where to install (default: current folder)
    -t, --type TYPE         🎯 What kind of project you have (nodejs, python, java, etc.)
    -e, --env ENV           🌍 Environment (development, staging, production)
    --skip-deps             ⚡ Skip installing dependencies (faster)
    --verbose               🔍 Show detailed output (for troubleshooting)
    -h, --help              📖 Show this help message

💡 Examples:
    $0                                          # Install here with auto-detection (easiest!)
    $0 --type nodejs --env production           # For Node.js production deployment
    $0 --dir /path/to/project --type python     # Install in specific folder for Python
    $0 --skip-deps                              # Quick install without dependencies

🎯 Project Types We Support:
    - nodejs     📱 (Node.js, React, Vue, Angular, Next.js)
    - python     🐍 (Django, Flask, FastAPI, Streamlit)
    - java       ☕ (Spring Boot, Maven, Gradle)
    - cpp        ⚡ (CMake, Make, Qt)
    - go         🐹 (Standard Go projects, Gin, Echo)
    - php        🐘 (Laravel, Symfony, WordPress)
    - ruby       💎 (Rails, Sinatra)
    - auto       🤖 (Let EasyDeploy figure it out - recommended!)

📞 Need help? Visit: https://easydeploy.com/docs
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            -t|--type)
                PROJECT_TYPE="$2"
                shift 2
                ;;
            -e|--env)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Auto-detect what kind of project this is (pretty smart!)
detect_project_type() {
    log_step "🔍 Looking at your project to figure out what type it is..."
    
    if [[ -f "package.json" ]]; then
        log_info "📱 Found package.json - This looks like a Node.js project!"
        echo "nodejs"
    elif [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
        log_info "🐍 Found Python files - This looks like a Python project!"
        echo "python"
    elif [[ -f "pom.xml" || -f "build.gradle" ]]; then
        log_info "☕ Found Java build files - This looks like a Java project!"
        echo "java"
    elif [[ -f "CMakeLists.txt" || -f "Makefile" ]]; then
        log_info "⚡ Found C/C++ build files - This looks like a C/C++ project!"
        echo "cpp"
    elif [[ -f "go.mod" ]]; then
        log_info "🐹 Found go.mod - This looks like a Go project!"
        echo "go"
    elif [[ -f "composer.json" ]]; then
        log_info "🐘 Found composer.json - This looks like a PHP project!"
        echo "php"
    elif [[ -f "Gemfile" ]]; then
        log_info "💎 Found Gemfile - This looks like a Ruby project!"
        echo "ruby"
    elif [[ -f "Dockerfile" ]]; then
        log_info "🐳 Found Dockerfile - This looks like a Docker project!"
        echo "docker"
    else
        log_info "🤷 Couldn't detect project type, but that's okay! Using generic setup."
        echo "generic"
    fi
}

# Check Git repository status and provide helpful guidance
check_git_repository() {
    log_title "Checking Git Repository Status"
    
    # Check if current directory is a Git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        log_warning "Current directory is not a Git repository"
        echo
        echo -e "🔧 ${YELLOW}EasyDeploy works best with Git repositories. Here's how to set one up:${NC}"
        echo
        echo -e "  ${BLUE}Option 1: Initialize Git repository here${NC}"
        echo -e "    1. ${BLUE}git init${NC}"
        echo -e "    2. ${BLUE}git add .${NC}"
        echo -e "    3. ${BLUE}git commit -m \"Initial commit\"${NC}"
        echo
        echo -e "  ${BLUE}Option 2: Navigate to existing Git repository${NC}"
        echo -e "    1. ${BLUE}cd /path/to/your/git/project${NC}"
        echo "    2. Run this installer again"
        echo
        
        while true; do
            echo -n "Would you like to initialize Git repository here? (y/N): "
            read -r response
            case $response in
                [Yy]* ) 
                    log_info "Initializing Git repository..."
                    git init
                    log_success "Git repository initialized!"
                    break
                    ;;
                [Nn]* | "" )
                    log_info "Continuing without Git repository initialization"
                    log_warning "Note: Some CI/CD features require a Git repository"
                    break
                    ;;
                * )
                    echo "Please answer yes or no."
                    ;;
            esac
        done
        echo
    else
        log_success "Git repository detected"
        
        # Check if Git remotes exist
        if ! git remote | grep -q .; then
            log_warning "No Git remotes found - repository not connected to GitHub"
            echo
            echo -e "🔧 ${YELLOW}To fully use EasyDeploy's features, connect this repository to GitHub:${NC}"
            echo
            echo -e "  ${BLUE}Option 1: Create new GitHub repository${NC}"
            echo -e "    1. ${BLUE}gh repo create your-repo-name --public${NC}"
            echo -e "    2. ${BLUE}git remote add origin https://github.com/username/your-repo-name.git${NC}"
            echo -e "    3. ${BLUE}git push -u origin main${NC}"
            echo
            echo -e "  ${BLUE}Option 2: Connect to existing repository${NC}"
            echo -e "    1. ${BLUE}git remote add origin https://github.com/username/existing-repo.git${NC}"
            echo -e "    2. ${BLUE}git push -u origin main${NC}"
            echo
            
            while true; do
                echo -n "Would you like to create a new GitHub repository now? (y/N): "
                read -r response
                case $response in
                    [Yy]* )
                        echo -n "Enter repository name: "
                        read -r repo_name
                        if [[ -n "$repo_name" ]]; then
                            log_info "Creating GitHub repository: $repo_name"
                            if gh repo create "$repo_name" --public; then
                                git remote add origin "https://github.com/$(gh api user --jq .login)/$repo_name.git"
                                log_success "Repository created and remote added!"
                                
                                # Offer to push
                                echo -n "Push current code to GitHub? (Y/n): "
                                read -r push_response
                                case $push_response in
                                    [Nn]* )
                                        log_info "You can push later with: git push -u origin main"
                                        ;;
                                    * )
                                        if git add . && git commit -m "Initial commit for EasyDeploy setup" && git push -u origin main; then
                                            log_success "Code pushed to GitHub!"
                                        else
                                            log_warning "Failed to push. You can try manually later."
                                        fi
                                        ;;
                                esac
                            else
                                log_error "Failed to create repository"
                            fi
                        fi
                        break
                        ;;
                    [Nn]* | "" )
                        log_info "You can set up GitHub connection later"
                        break
                        ;;
                    * )
                        echo "Please answer yes or no."
                        ;;
                esac
            done
            echo
        else
            local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
            if [[ -n "$remote_url" ]]; then
                log_success "Git remote configured: $remote_url"
                
                # Check if we can access the GitHub repository
                if command -v gh &> /dev/null && gh auth status &> /dev/null; then
                    if gh repo view &> /dev/null; then
                        log_success "GitHub repository is accessible"
                    else
                        log_warning "Cannot access GitHub repository - check permissions"
                    fi
                fi
            fi
        fi
    fi
}

# Check if you have everything needed to run EasyDeploy
check_dependencies() {
    log_title "Checking What You Need"
    
    local missing_deps=()
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        missing_deps+=("github-cli")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        
        if [[ "$SKIP_DEPS" == "false" ]]; then
            install_dependencies "${missing_deps[@]}"
        else
            log_warning "Skipping dependency installation. Some features may not work."
        fi
    else
        log_success "All dependencies are installed"
    fi
}

# Install system dependencies
install_dependencies() {
    local deps=("$@")
    log_title "Installing Dependencies"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Update package list
        sudo apt update
        
        for dep in "${deps[@]}"; do
            case $dep in
                "git")
                    sudo apt install -y git
                    ;;
                "jq")
                    sudo apt install -y jq
                    ;;
                "github-cli")
                    # Install GitHub CLI
                    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                    sudo apt update && sudo apt install -y gh
                    ;;
            esac
        done
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS with Homebrew
        if command -v brew &> /dev/null; then
            for dep in "${deps[@]}"; do
                case $dep in
                    "git"|"jq")
                        brew install "$dep"
                        ;;
                    "github-cli")
                        brew install gh
                        ;;
                esac
            done
        else
            log_error "Homebrew not found. Please install dependencies manually."
            exit 1
        fi
    fi
}

# Copy CI/CD files
install_cicd_files() {
    log_title "Installing CI/CD System Files"
    
    local source_dir="$PROJECT_ROOT"
    
    # Create directory structure
    mkdir -p .github/workflows
    mkdir -p config
    mkdir -p docs
    mkdir -p scripts
    
    # Copy workflow files
    for workflow in auto-cicd.yml cicd-toolkit.yml; do
        if [[ -f "$source_dir/.github/workflows/$workflow" ]]; then
            cp "$source_dir/.github/workflows/$workflow" .github/workflows/
            log_success "Copied workflow: $workflow"
        fi
    done
    
    # Copy scripts (skip if installing inside source repository)
    if [[ "$PWD" != "$source_dir" ]]; then
        if [[ -d "$source_dir/scripts" ]]; then
            cp -R "$source_dir/scripts" .
            find scripts -name "*.sh" -exec chmod +x {} +
            log_success "Copied script toolkit"
        fi
    else
        log_info "Detected EasyDeploy repository, using existing scripts directory"
    fi
    
    # Copy configuration
    if [[ -f "$source_dir/config/auto_cicd_config.json" ]]; then
        cp "$source_dir/config/auto_cicd_config.json" config/
        log_success "Copied configuration file"
    fi
    
    # Copy documentation
    if [[ -d "$source_dir/docs" ]]; then
        cp -r "$source_dir/docs"/* docs/ 2>/dev/null || true
        log_success "Copied documentation"
    fi
}

# Configure for specific project type
configure_project() {
    log_title "Configuring for Project Type: $PROJECT_TYPE"
    
    # Update configuration based on project type
    if [[ -f "config/auto_cicd_config.json" ]]; then
        # Create temporary config with project-specific settings
        local temp_config=$(mktemp)
        
        case $PROJECT_TYPE in
            "nodejs")
                jq --arg type "nodejs" \
                   --argjson build_commands '["npm ci", "npm run build", "npm test"]' \
                   --argjson deploy_commands '["npm run deploy"]' \
                   '.project_type = $type | .build_commands = $build_commands | .deploy_commands = $deploy_commands' \
                   config/auto_cicd_config.json > "$temp_config"
                ;;
            "python")
                jq --arg type "python" \
                   --argjson build_commands '["pip install -r requirements.txt", "python -m pytest", "python setup.py build"]' \
                   --argjson deploy_commands '["python -m pip install --upgrade .", "python deploy.py"]' \
                   '.project_type = $type | .build_commands = $build_commands | .deploy_commands = $deploy_commands' \
                   config/auto_cicd_config.json > "$temp_config"
                ;;
            "java")
                jq --arg type "java" \
                   --argjson build_commands '["./mvnw clean compile", "./mvnw test", "./mvnw package"]' \
                   --argjson deploy_commands '["./mvnw deploy"]' \
                   '.project_type = $type | .build_commands = $build_commands | .deploy_commands = $deploy_commands' \
                   config/auto_cicd_config.json > "$temp_config"
                ;;
            "cpp")
                jq --arg type "cpp" \
                   --argjson build_commands '["mkdir -p build", "cd build && cmake ..", "cd build && make", "cd build && ctest"]' \
                   --argjson deploy_commands '["cd build && make install"]' \
                   '.project_type = $type | .build_commands = $build_commands | .deploy_commands = $deploy_commands' \
                   config/auto_cicd_config.json > "$temp_config"
                ;;
            "go")
                jq --arg type "go" \
                   --argjson build_commands '["go mod tidy", "go test ./...", "go build ."]' \
                   --argjson deploy_commands '["go install ."]' \
                   '.project_type = $type | .build_commands = $build_commands | .deploy_commands = $deploy_commands' \
                   config/auto_cicd_config.json > "$temp_config"
                ;;
            *)
                cp config/auto_cicd_config.json "$temp_config"
                ;;
        esac
        
        mv "$temp_config" config/auto_cicd_config.json
        log_success "Configuration updated for $PROJECT_TYPE"
    fi
}

# Setup GitHub authentication
setup_github_auth() {
    log_title "GitHub Authentication Setup"
    
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI already authenticated"
        return 0
    fi
    
    log_info "GitHub CLI needs authentication for full functionality"
    echo
    echo "Please choose authentication method:"
    echo "1. Browser authentication (recommended)"
    echo "2. Token authentication"
    echo "3. Skip authentication (limited functionality)"
    echo
    
    read -p "Enter your choice (1-3): " auth_choice
    
    case $auth_choice in
        1)
            log_info "Starting browser authentication..."
            gh auth login
            ;;
        2)
            log_info "Please create a Personal Access Token at: https://github.com/settings/tokens"
            echo "Required scopes: repo, workflow, read:org"
            echo
            read -p "Enter your token: " -s token
            echo
            echo "$token" | gh auth login --with-token
            ;;
        3)
            log_warning "Skipping authentication. Some features will not work."
            return 0
            ;;
        *)
            log_warning "Invalid choice. Skipping authentication."
            return 0
            ;;
    esac
    
    if gh auth status &> /dev/null; then
        log_success "GitHub authentication successful!"
    else
        log_warning "Authentication incomplete. You can run 'gh auth login' later."
    fi
}

# Test the installation
test_installation() {
    log_title "Testing Installation"
    
    local errors=0
    
    # Test script executability
    if [[ -x "scripts/deploy/auto-deploy.sh" ]]; then
        log_success "Trigger script is executable"
    else
        log_error "Trigger script is not executable"
        ((errors++))
    fi
    
    # Test configuration
    if [[ -f "config/auto_cicd_config.json" ]] && jq . config/auto_cicd_config.json &> /dev/null; then
        log_success "Configuration file is valid"
    else
        log_error "Configuration file is invalid or missing"
        ((errors++))
    fi
    
    # Test workflow file
    if [[ -f ".github/workflows/auto-cicd.yml" ]]; then
        log_success "GitHub Actions workflow is present"
    else
        log_error "GitHub Actions workflow is missing"
        ((errors++))
    fi
    
    # Run system status check
    if [[ -x "scripts/deploy/status.sh" ]]; then
        log_info "Running system status check..."
        ./scripts/deploy/status.sh status
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "Installation test passed!"
        return 0
    else
        log_error "Installation test failed with $errors errors"
        return 1
    fi
}

# Show completion message
show_completion() {
    log_title "Installation Complete!"
    
    echo
    echo "🎉 Universal Auto CI/CD system has been successfully installed!"
    echo
    echo "📁 Files installed:"
    echo "   - .github/workflows/auto-cicd.yml (GitHub Actions workflow)"
    echo "   - scripts/ (CI/CD management toolkit)"
    echo "   - config/auto_cicd_config.json (Configuration)"
    echo "   - docs/ (Documentation)"
    echo
    echo "🚀 Next steps:"
    echo "   1. Review configuration: nano config/auto_cicd_config.json"
    echo "   2. Test the system: ./scripts/deploy/status.sh status"
    echo "   3. Trigger a deployment: ./scripts/deploy/auto-deploy.sh --help"
    echo "   4. Commit and push: git add . && git commit -m 'Add auto CI/CD system' && git push"
    echo
    echo "📚 Documentation:"
    echo "   - Quick start: ./scripts/deploy/auto-deploy.sh --help"
    echo "   - Full guide: docs/AUTO_CICD_GUIDE.md"
    echo
    echo "🔧 Troubleshooting:"
    echo "   - Run diagnostics: ./scripts/deploy/status.sh interactive"
    echo "   - Check logs: ./scripts/deploy/status.sh logs"
    echo
}

# Main installation process
main() {
    echo "🚀 Universal Auto CI/CD Installation Script"
    echo "=========================================="
    
    # Parse arguments
    parse_args "$@"
    
    # Set installation directory
    if [[ -n "$INSTALL_DIR" ]]; then
        cd "$INSTALL_DIR" || exit 1
        log_info "Installing in: $(pwd)"
    else
        cd "$INSTALL_TARGET_DIR" || exit 1
        log_info "Installing in current directory: $(pwd)"
    fi
    
    # Check Git repository status
    check_git_repository
    
    # Auto-detect project type if needed
    if [[ "$PROJECT_TYPE" == "auto" ]]; then
        PROJECT_TYPE=$(detect_project_type)
        log_info "Detected project type: $PROJECT_TYPE"
    fi
    
    # Run installation steps
    check_dependencies
    install_cicd_files
    configure_project
    setup_github_auth
    
    # Test installation
    if test_installation; then
        show_completion
        exit 0
    else
        log_error "Installation completed with errors. Please check the output above."
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
