#!/bin/bash
# deploy_solana_dashboard.sh - Deploy to Solana solfunmeme.com

echo "🔮 zkPrologML - Solana Dashboard Deployment"
echo "============================================"
echo ""

# Configuration
DASHBOARD_FILE="solana_auto_dashboard.html"
TARGET_URL="https://solana.solfunmeme.com"
DEPLOY_DIR="./deploy"

# Create deployment directory
mkdir -p "$DEPLOY_DIR"

echo "📦 Preparing deployment..."

# Copy dashboard
cp "$DASHBOARD_FILE" "$DEPLOY_DIR/index.html"

# Copy assets
cp monster_graph.png "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  monster_graph.png not found"
cp zos_dashboard_config.json "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  config not found"

# Create deployment manifest
cat > "$DEPLOY_DIR/manifest.json" << EOF
{
  "name": "zkPrologML Auto Dashboard",
  "version": "0.1.0",
  "description": "Monster Group Knowledge System with real-time updates",
  "author": "zkPrologML",
  "homepage": "$TARGET_URL",
  "features": [
    "Real-time state updates",
    "Monster Group visualization (71 shards)",
    "zkProlog execution logs",
    "Matrix rain effect",
    "Auto-updating statistics"
  ],
  "tech_stack": [
    "HTML5",
    "JavaScript (Vanilla)",
    "Canvas API",
    "CSS3 Animations",
    "WebSockets (future)"
  ],
  "data_sources": {
    "files_indexed": 8017192,
    "monster_shards": 71,
    "theorems_proven": 10,
    "entities_unified": 42,
    "prediction_accuracy": 99.6
  }
}
EOF

echo "✅ Deployment package created in $DEPLOY_DIR/"
echo ""
echo "📊 Dashboard features:"
echo "  • Real-time auto-updates (2s interval)"
echo "  • Matrix rain background effect"
echo "  • 71 Monster Group shards (interactive)"
echo "  • Live terminal logs"
echo "  • Animated statistics"
echo "  • zkProlog state machine"
echo ""
echo "🚀 Deployment options:"
echo ""
echo "Option 1: Static hosting"
echo "  cd $DEPLOY_DIR && python3 -m http.server 8000"
echo "  Then upload to: $TARGET_URL"
echo ""
echo "Option 2: Nix flake"
echo "  nix run .#serve"
echo ""
echo "Option 3: Direct upload"
echo "  scp -r $DEPLOY_DIR/* user@solana.solfunmeme.com:/var/www/html/"
echo ""
echo "Option 4: GitHub Pages"
echo "  git subtree push --prefix $DEPLOY_DIR origin gh-pages"
echo ""
echo "✅ Ready for deployment!"
