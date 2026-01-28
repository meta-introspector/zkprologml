#!/usr/bin/env bash
# deploy_to_solana.sh - Deploy zkPrologML dashboard to Solana site

set -euo pipefail

# Source keys if available
[ -f ~/.agentrc ] && source ~/.agentrc

REMOTE_HOST="${SOLANA_HOST:-localhost}"
REMOTE_USER="${SOLANA_USER:-$USER}"
REMOTE_PATH="${SOLANA_PATH:-/var/www/html}"
LOCAL_DIR="./deploy"

echo "🔮 zkPrologML - Deploying to Solana"
echo "===================================="
echo ""
echo "Target: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
echo ""

# Check if deploy directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "❌ Deploy directory not found. Run ./deploy_solana_dashboard.sh first"
    exit 1
fi

# Test SSH connection
echo "🔍 Testing connection..."
if ! ssh -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "echo '✅ Connected'" 2>/dev/null; then
    echo "❌ Cannot connect to ${REMOTE_HOST}"
    echo ""
    echo "Set environment variables:"
    echo "  export SOLANA_HOST=your.server.com"
    echo "  export SOLANA_USER=your_user"
    echo "  export SOLANA_PATH=/var/www/html"
    exit 1
fi

# Rsync files
echo ""
echo "📦 Syncing files..."
rsync -avz --progress \
    --exclude='.git' \
    --exclude='*.sh' \
    "${LOCAL_DIR}/" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Dashboard: https://${REMOTE_HOST}/"
echo ""
echo "Test locally first:"
echo "  cd deploy && python3 -m http.server 8000"
echo "  Open: http://localhost:8000"
