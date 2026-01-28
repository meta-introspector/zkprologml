#!/bin/bash
echo "🔍 Finding all Coq repos..."

# Find MetaCoq repos
plocate -i "metacoq" | grep ".git$" | sed 's|/.git$||' | sort -u > all_coq_repos.txt

# Find Coq repos
plocate -i "/coq" | grep ".git$" | sed 's|/.git$||' | sort -u >> all_coq_repos.txt

# Deduplicate
sort -u all_coq_repos.txt -o all_coq_repos.txt

echo "📦 Found $(wc -l < all_coq_repos.txt) repos"

echo ""
echo "📥 Updating all repos..."
while read repo; do
    if [ -d "$repo" ]; then
        echo ""
        echo "→ $repo"
        cd "$repo" && git pull 2>&1 | head -3 || echo "  ✗ Failed"
    fi
done < all_coq_repos.txt

echo ""
echo "✅ Update complete!"
echo "📊 Summary:"
wc -l < all_coq_repos.txt
