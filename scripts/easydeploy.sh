#!/bin/bash

# EasyDeploy Main Menu 🚀
# Your one-stop command for all deployment needs!

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Friendly colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Enhanced logging with emojis
log_title() { echo -e "\n${PURPLE}🚀 $1${NC}\n"; }
log_step() { echo -e "${BLUE}📋 $1${NC}"; }
log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

cd "$PROJECT_ROOT"

# Show the main menu
show_menu() {
    clear
    log_title "Welcome to EasyDeploy!"
    echo "Deploy your apps effortlessly - No DevOps experience required!"
    echo
    echo "🎯 Choose what you want to do:"
    echo
    echo "  ${GREEN}[1]${NC} 🔰 ${BLUE}Complete Beginner Setup${NC}     - Never deployed before? Start here!"
    echo "  ${GREEN}[2]${NC} ⚡ ${BLUE}Quick Install${NC}               - Fast setup for experienced users"
    echo "  ${GREEN}[3]${NC} ⚙️  ${BLUE}Setup Environment${NC}           - Configure deployment settings"
    echo "  ${GREEN}[4]${NC} 🚀 ${BLUE}Deploy Now${NC}                  - Deploy your app right now"
    echo "  ${GREEN}[5]${NC} 📊 ${BLUE}Check Status${NC}                - See what's happening"
    echo "  ${GREEN}[6]${NC} 🔑 ${BLUE}GitHub Authentication${NC}       - Connect to GitHub"
    echo "  ${GREEN}[7]${NC} 🆘 ${BLUE}Troubleshoot${NC}                - Fix problems"
    echo "  ${GREEN}[8]${NC} 📚 ${BLUE}View Documentation${NC}          - Read guides and help"
    echo "  ${GREEN}[9]${NC} 🏃 ${BLUE}Quick Commands${NC}              - Common deployment shortcuts"
    echo
    echo "  ${YELLOW}[0]${NC} 👋 ${YELLOW}Exit${NC}"
    echo
}

# Quick commands submenu
show_quick_commands() {
    clear
    log_title "Quick Commands"
    echo "Fast shortcuts for common tasks:"
    echo
    echo "  ${GREEN}[1]${NC} 🚀 Deploy with commit message"
    echo "  ${GREEN}[2]${NC} 🧪 Deploy to staging"
    echo "  ${GREEN}[3]${NC} 🎯 Deploy to production"
    echo "  ${GREEN}[4]${NC} 📊 Check deployment status"
    echo "  ${GREEN}[5]${NC} 📝 View deployment logs"
    echo "  ${GREEN}[6]${NC} 🔄 Rollback last deployment"
    echo
    echo "  ${YELLOW}[0]${NC} ⬅️  Back to main menu"
    echo
}

# Documentation submenu
show_documentation() {
    clear
    log_title "Documentation & Help"
    echo "Get help and learn more about EasyDeploy:"
    echo
    echo "  ${GREEN}[1]${NC} 🔰 Complete Beginner's Guide"
    echo "  ${GREEN}[2]${NC} 🤔 Frequently Asked Questions (FAQ)"
    echo "  ${GREEN}[3]${NC} 📖 Installation Guide"
    echo "  ${GREEN}[4]${NC} ⚙️  Configuration Guide"
    echo "  ${GREEN}[5]${NC} 🆘 Troubleshooting Guide"
    echo "  ${GREEN}[6]${NC} 💡 Best Practices"
    echo "  ${GREEN}[7]${NC} 🌐 Open GitHub Repository"
    echo "  ${GREEN}[8]${NC} 💬 Join Discord Community"
    echo
    echo "  ${YELLOW}[0]${NC} ⬅️  Back to main menu"
    echo
}

# Execute the chosen option
execute_option() {
    case $1 in
        1)
            log_step "Starting Complete Beginner Setup..."
            if [[ -f "$PROJECT_ROOT/scripts/init/beginner-setup.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/init/beginner-setup.sh"
            else
                log_warning "Beginner setup script not found!"
                echo "Please make sure you're in the EasyDeploy directory."
            fi
            ;;
        2)
            log_step "Starting Quick Install..."
            if [[ -f "$PROJECT_ROOT/scripts/init/install.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/init/install.sh"
            else
                log_warning "Install script not found!"
                echo "Please make sure you're in the EasyDeploy directory."
            fi
            ;;
        3)
            log_step "Opening Environment Setup..."
            if [[ -f "$PROJECT_ROOT/scripts/config/environment-setup.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/config/environment-setup.sh"
            else
                log_warning "Environment setup script not found!"
            fi
            ;;
        4)
            log_step "Starting Deployment..."
            if [[ -f "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" interactive
            else
                log_warning "Deploy script not found!"
            fi
            ;;
        5)
            log_step "Checking Status..."
            if [[ -f "$PROJECT_ROOT/scripts/deploy/status.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/deploy/status.sh" interactive
            else
                log_warning "Status script not found!"
            fi
            ;;
        6)
            log_step "Opening GitHub Authentication..."
            if [[ -f "$PROJECT_ROOT/scripts/config/github-auth.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/config/github-auth.sh"
            else
                log_warning "GitHub auth script not found!"
            fi
            ;;
        7)
            log_step "Opening Troubleshoot Tools..."
            if [[ -f "$PROJECT_ROOT/scripts/deploy/troubleshoot.sh" ]]; then
                bash "$PROJECT_ROOT/scripts/deploy/troubleshoot.sh" interactive
            else
                log_warning "Troubleshoot script not found!"
            fi
            ;;
        8)
            show_documentation_menu
            ;;
        9)
            show_quick_commands_menu
            ;;
        0)
            echo
            log_success "Thanks for using EasyDeploy! Happy deploying! 🚀"
            exit 0
            ;;
        *)
            log_warning "Invalid option. Please choose a number from 0-9."
            ;;
    esac
}

# Quick commands execution
execute_quick_command() {
    case $1 in
        1)
            log_step "Deploy with commit message..."
            bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" commit-trigger
            ;;
        2)
            log_step "Deploying to staging..."
            bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" commit-trigger -e staging
            ;;
        3)
            log_step "Deploying to production..."
            bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" commit-trigger -e production
            ;;
        4)
            log_step "Checking deployment status..."
            bash "$PROJECT_ROOT/scripts/deploy/status.sh" status
            ;;
        5)
            log_step "Viewing deployment logs..."
            bash "$PROJECT_ROOT/scripts/deploy/status.sh" logs
            ;;
        6)
            log_step "Rolling back last deployment..."
            bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" rollback
            ;;
        0)
            return 0
            ;;
        *)
            log_warning "Invalid option. Please choose a number from 0-6."
            ;;
    esac
}

# Documentation menu execution
execute_documentation() {
    case $1 in
        1)
            log_step "Opening Beginner's Guide..."
            if [[ -f "docs/BEGINNER_GUIDE.md" ]]; then
                if command -v code &> /dev/null; then
                    code docs/BEGINNER_GUIDE.md
                elif command -v less &> /dev/null; then
                    less docs/BEGINNER_GUIDE.md
                else
                    cat docs/BEGINNER_GUIDE.md
                fi
            else
                echo "Guide not found. Visit: https://github.com/easydeploy/easydeploy/blob/main/docs/BEGINNER_GUIDE.md"
            fi
            ;;
        2)
            log_step "Opening FAQ..."
            if [[ -f "docs/FAQ.md" ]]; then
                if command -v code &> /dev/null; then
                    code docs/FAQ.md
                elif command -v less &> /dev/null; then
                    less docs/FAQ.md
                else
                    cat docs/FAQ.md
                fi
            else
                echo "FAQ not found. Visit: https://github.com/easydeploy/easydeploy/blob/main/docs/FAQ.md"
            fi
            ;;
        3|4|5|6)
            local files=("docs/INSTALLATION.md" "docs/CONFIGURATION.md" "docs/TROUBLESHOOTING.md" "docs/BEST_PRACTICES.md")
            local file="${files[$1-3]}"
            if [[ -f "$file" ]]; then
                if command -v code &> /dev/null; then
                    code "$file"
                elif command -v less &> /dev/null; then
                    less "$file"
                else
                    cat "$file"
                fi
            else
                echo "Documentation not found."
            fi
            ;;
        7)
            log_step "Opening GitHub Repository..."
            if command -v xdg-open &> /dev/null; then
                xdg-open "https://github.com/easydeploy/easydeploy"
            elif command -v open &> /dev/null; then
                open "https://github.com/easydeploy/easydeploy"
            else
                echo "Visit: https://github.com/easydeploy/easydeploy"
            fi
            ;;
        8)
            log_step "Opening Discord Community..."
            if command -v xdg-open &> /dev/null; then
                xdg-open "https://discord.gg/easydeploy"
            elif command -v open &> /dev/null; then
                open "https://discord.gg/easydeploy"
            else
                echo "Join our Discord: https://discord.gg/easydeploy"
            fi
            ;;
        0)
            return 0
            ;;
        *)
            log_warning "Invalid option. Please choose a number from 0-8."
            ;;
    esac
}

# Quick commands menu loop
show_quick_commands_menu() {
    while true; do
        show_quick_commands
        echo -n "Choose an option (0-6): "
        read -r choice
        
        if [[ $choice == "0" ]]; then
            break
        fi
        
        execute_quick_command "$choice"
        echo
        echo "Press Enter to continue..."
        read -r
    done
}

# Documentation menu loop
show_documentation_menu() {
    while true; do
        show_documentation
        echo -n "Choose an option (0-8): "
        read -r choice
        
        if [[ $choice == "0" ]]; then
            break
        fi
        
        execute_documentation "$choice"
        echo
        echo "Press Enter to continue..."
        read -r
    done
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "scripts/init/beginner-setup.sh" && ! -f "scripts/init/install.sh" ]]; then
        log_warning "EasyDeploy scripts not found in current directory!"
        echo
        echo "Please make sure you're in the EasyDeploy directory and try again."
        echo "If you haven't installed EasyDeploy yet, run:"
        echo
        echo "  git clone https://github.com/KahanaT800/cicd-toolkit.git"
        echo "  cd easydeploy"
        echo "  ./scripts/easydeploy.sh"
        echo
        exit 1
    fi
}

# Main menu loop
main() {
    check_directory
    
    # Handle command line arguments for direct execution
    if [[ $# -gt 0 ]]; then
        case $1 in
            "beginner"|"1")
                execute_option 1
                ;;
            "install"|"2")
                execute_option 2
                ;;
            "setup"|"3")
                execute_option 3
                ;;
            "deploy"|"4")
                execute_option 4
                ;;
            "status"|"5")
                execute_option 5
                ;;
            "auth"|"6")
                execute_option 6
                ;;
            "help"|"troubleshoot"|"7")
                execute_option 7
                ;;
            "docs"|"8")
                execute_option 8
                ;;
            "quick"|"9")
                execute_option 9
                ;;
            *)
                echo "Usage: $0 [beginner|install|setup|deploy|status|auth|help|docs|quick]"
                echo "Or run without arguments for interactive menu."
                ;;
        esac
        return
    fi
    
    # Interactive menu loop
    while true; do
        show_menu
        echo -n "Choose an option (0-9): "
        read -r choice
        
        execute_option "$choice"
        
        if [[ $choice != "0" ]]; then
            echo
            echo "Press Enter to return to main menu..."
            read -r
        fi
    done
}

# Run the main function
main "$@"
