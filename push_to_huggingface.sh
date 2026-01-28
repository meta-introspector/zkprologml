#!/bin/bash
# push_to_huggingface.sh - Push to HuggingFace Space via SSH

SPACE="introspector/zkprologml"
HF_REPO="git@hf.co:spaces/$SPACE"

echo "🚀 PUSH TO HUGGINGFACE"
echo "═══════════════════════════════════════════════════════════"
echo
echo "Space: $SPACE"
echo "Repo: $HF_REPO"
echo

# Create temp directory for HF space
TMP_DIR=$(mktemp -d)
echo "📁 Temp dir: $TMP_DIR"

# Copy files
echo "📦 Copying files..."
cp -r huggingface/* "$TMP_DIR/"
cp data/proofs/generated/llm*.txt "$TMP_DIR/"

cd "$TMP_DIR"

# Initialize git if needed
if [ ! -d .git ]; then
    echo "🔧 Initializing git..."
    git init
    git remote add origin "$HF_REPO"
fi

# Commit and push
echo "📝 Committing..."
git add .
git commit -m "feat: zkPrologML llm.txt generator

- Generate llm.txt from repo
- Chunk into 8KB pieces
- Gradio interface for NotebookLM
- REST API for chunk access"

echo "⬆️  Pushing to HuggingFace..."
git push -u origin main --force

echo
echo "✅ PUSHED TO HUGGINGFACE"
echo "🌐 https://huggingface.co/spaces/$SPACE"

# Cleanup
cd -
rm -rf "$TMP_DIR"
