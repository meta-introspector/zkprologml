#!/bin/bash
echo "🔍 Finding all OCaml repos..."

# Find OCaml repos
plocate -i "ocaml" | grep ".git$" | sed 's|/.git$||' | sort -u > all_ocaml_repos.txt

echo "📦 Found $(wc -l < all_ocaml_repos.txt) OCaml repos"

echo ""
echo "📥 Updating all repos..."
while read repo; do
    if [ -d "$repo" ]; then
        echo ""
        echo "→ $repo"
        cd "$repo" && git pull 2>&1 | head -3 || echo "  ✗ Failed"
    fi
done < all_ocaml_repos.txt

echo ""
echo "✅ Update complete!"
echo "📊 Total repos: $(wc -l < all_ocaml_repos.txt)"
