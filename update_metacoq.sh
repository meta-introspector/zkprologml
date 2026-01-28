#!/bin/bash
echo "🔍 Finding MetaCoq repos..."
plocate -i "metacoq" | grep ".git$" | sed 's|/.git$||' | sort -u > metacoq_repos.txt

echo "📦 Found repos:"
cat metacoq_repos.txt

echo ""
echo "📥 Updating repos..."
while read repo; do
    if [ -d "$repo" ]; then
        echo "→ $repo"
        cd "$repo" && git pull 2>&1 | head -2
    fi
done < metacoq_repos.txt

echo ""
echo "✅ Done!"
