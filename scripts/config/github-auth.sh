#!/bin/bash

# GitHub CLI Authentication Script
# This script helps complete the environment setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== GitHub CLI Authentication Assistant ==="
echo

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found. Please install it first:"
    echo "   ./scripts/config/environment-setup.sh deps"
    exit 1
fi

# Check current authentication status
echo "Checking current authentication status..."
if gh auth status &> /dev/null; then
    echo "✅ GitHub CLI is already authenticated!"
    gh auth status
    echo
    echo "Testing API access..."
    if gh api user &> /dev/null; then
        echo "✅ API access working correctly"
        echo "🎉 Environment setup complete!"
        exit 0
    else
        echo "⚠️ Authentication exists but API access failed"
        echo "You may need to re-authenticate"
    fi
else
    echo "ℹ️ GitHub CLI not authenticated yet"
fi

echo
echo "Choose authentication method:"
echo "1) Browser authentication (recommended)"
echo "2) Token authentication" 
echo "3) Check status only"
echo "4) Skip authentication"
echo
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo
        echo "Starting browser authentication..."
        echo "📋 Steps:"
        echo "1. A browser will open (or copy the URL manually)"
        echo "2. Enter the device code when prompted"
        echo "3. Authorize the application"
        echo
        read -p "Press Enter to continue..."
        gh auth login
        ;;
    2)
        echo
        echo "Token authentication selected"
        echo "📋 Steps to get a token:"
        echo "1. Visit: https://github.com/settings/tokens"
        echo "2. Click 'Generate new token (classic)'"
        echo "3. Select scopes: repo, workflow, read:org"
        echo "4. Copy the generated token"
        echo
        echo "Now running token authentication..."
        gh auth login --with-token
        ;;
    3)
        echo
        echo "Current status:"
        gh auth status 2>&1 || echo "Not authenticated"
        ;;
    4)
        echo
        echo "⚠️ Skipping authentication"
        echo "Note: Some features will not work without authentication:"
        echo "- Conflict management"
        echo "- API triggers"
        echo "- Repository operations"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo
echo "=== Final Status Check ==="
if gh auth status &> /dev/null; then
    echo "✅ Authentication successful!"
    gh auth status
    echo
    echo "Testing system components..."
    ./scripts/deploy/status.sh status
else
    echo "⚠️ Authentication incomplete"
    echo "You can run this script again anytime: ./scripts/config/github-auth.sh"
fi
