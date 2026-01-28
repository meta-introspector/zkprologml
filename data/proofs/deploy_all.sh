#!/usr/bin/env bash
# deploy_all.sh - Deploy to HuggingFace, Vercel, and Cloudflare

set -euo pipefail

cd "$(dirname "$0")/deploy"

echo "🚀 zkPrologML - Multi-Platform Deployment"
echo "=========================================="
echo ""

# HuggingFace Spaces
echo "📦 1. HuggingFace Spaces"
echo "------------------------"
echo "Manual steps:"
echo "  1. Go to: https://huggingface.co/new-space"
echo "  2. Name: zkprologml-dashboard"
echo "  3. SDK: Static"
echo "  4. Upload files from ./deploy/"
echo ""

# Vercel
echo "📦 2. Vercel"
echo "------------"
if command -v vercel &> /dev/null; then
    echo "Deploying to Vercel..."
    vercel --prod
    echo "✅ Deployed to Vercel"
else
    echo "Install: npm i -g vercel"
    echo "Then run: vercel --prod"
fi
echo ""

# Cloudflare Pages
echo "📦 3. Cloudflare Pages"
echo "----------------------"
if command -v wrangler &> /dev/null; then
    echo "Deploying to Cloudflare..."
    wrangler pages deploy . --project-name=zkprologml-dashboard
    echo "✅ Deployed to Cloudflare"
else
    echo "Install: npm i -g wrangler"
    echo "Then run: wrangler pages deploy . --project-name=zkprologml-dashboard"
fi
echo ""

echo "=========================================="
echo "✅ Deployment instructions complete!"
echo ""
echo "URLs (after deployment):"
echo "  • HuggingFace: https://huggingface.co/spaces/YOUR_USERNAME/zkprologml-dashboard"
echo "  • Vercel: https://zkprologml-dashboard.vercel.app"
echo "  • Cloudflare: https://zkprologml-dashboard.pages.dev"
