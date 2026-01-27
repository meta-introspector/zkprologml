#!/bin/bash
# Extract key terms and search filesystem with locate

terms=(
    "github" "search" "index" "crawler" "scraper" "repository"
    "octocrab" "fuzzy" "fulltext" "inverted" "semantic"
    "cargo-search" "git-search" "code-search" "repo-search"
    "github-api" "github-client" "github-search"
)

echo "# Filesystem Search Results"
echo ""
echo "Searching for terms in filesystem using locate..."
echo ""

for term in "${terms[@]}"; do
    echo "## Term: $term"
    count=$(locate -i "$term" 2>/dev/null | grep -E '\.(rs|toml|md)$' | wc -l)
    echo "Found: $count files"
    locate -i "$term" 2>/dev/null | grep -E '\.(rs|toml|md)$' | head -5
    echo ""
done
