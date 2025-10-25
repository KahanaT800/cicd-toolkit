#!/bin/bash

# Wrapper around the reorganised troubleshoot toolkit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec bash "$PROJECT_ROOT/scripts/deploy/troubleshoot.sh" "$@"
