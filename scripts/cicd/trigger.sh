#!/bin/bash

# Backwards-compatible wrapper for the new auto-deploy toolkit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec bash "$PROJECT_ROOT/scripts/deploy/auto-deploy.sh" "$@"
