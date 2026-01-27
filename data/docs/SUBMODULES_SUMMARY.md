# GitHub Rust Repositories - Submodules Summary

This document provides an overview of all the GitHub repositories added as submodules for Rust-based GitHub search and related functionality.

## Search & Fuzzy Matching

### 1. fuse-rust
**Path:** `submodules/fuse-rust`  
**URL:** https://github.com/Blakeinstein/fuse-rust  
**Purpose:** Lightweight fuzzy search library ported from fuse-swift  
**Key Features:**
- Fuzzy string matching with configurable parameters
- Async support available
- Configurable location, distance, threshold, and case sensitivity
- Example search bar implementation using iced GUI framework

### 2. fulltext-search-rust
**Path:** `submodules/fulltext-search-rust`  
**URL:** https://github.com/obrhubr/fulltext-search-rust  
**Purpose:** Full-text search engine with inverted index using RocksDB and SQLite  
**Key Features:**
- Inverted index using RocksDB for key-value storage
- SQLite for text storage
- REST API with actix-web
- Proximity-based ranking for multi-word searches
- Routes: `/add`, `/edit`, `/remove`, `/search/all`, `/search/one`

### 3. search-engine
**Path:** `submodules/search-engine`  
**URL:** https://github.com/Dibisui445/search-engine  
**Purpose:** Custom web scraper and search engine with TF-IDF indexing  
**Key Features:**
- Concurrent web scraping with robots.txt compliance
- TF-IDF based inverted index
- REST API for search queries
- WordNet integration for dictionary definitions
- LibreTranslate API integration
- CLI interface for searching

## GitHub API Clients

### 4. github.alfredworkflow
**Path:** `submodules/github.alfredworkflow`  
**URL:** https://github.com/rossmacarthur/github.alfredworkflow  
**Purpose:** Alfred workflow to search GitHub repositories and pull requests  
**Key Features:**
- List repositories for users/organizations
- List pull requests for repositories
- Configurable commands via environment variables
- Token-based authentication with per-owner tokens

### 5. GitHubSearch
**Path:** `submodules/GitHubSearch`  
**URL:** https://github.com/davenportw15/GitHubSearch  
**Purpose:** Simple GitHub search client using hyper and serde  
**Dependencies:** hyper, hyper-native-tls, serde, serde_json

### 6. github-search-repository
**Path:** `submodules/github-search-repository`  
**URL:** https://github.com/mzumi/github-search-repository  
**Purpose:** GitHub Search API client (Rust reimplementation of Swift book example)  
**Note:** Japanese documentation - "書籍「Swift 実践入門」の Github Search API クライアントを Rust で再実装"

### 7. search-rustyn
**Path:** `submodules/search-rustyn`  
**URL:** https://github.com/jaiyankargupta/search-rustyn  
**Purpose:** Next.js application for searching GitHub repositories  
**Key Features:**
- Multiple search modes: ideas, repo names, owners, usernames
- README generator
- User battle feature (compare GitHub users)
- Modern UI with Tailwind CSS
- Next.js 14 with API routes

### 8. github-profile
**Path:** `submodules/github-profile`  
**URL:** https://github.com/neuodev/github-profile  
**Purpose:** GitHub API client to search and get user information  
**Features:** User profile lookup with visual interface

## GitHub CLI Extensions

### 9. gh-activity
**Path:** `submodules/gh-activity`  
**URL:** https://github.com/nogtk/gh-activity  
**Purpose:** GitHub CLI extension to search pull requests interactively  
**Key Features:**
- Interactive wrapper for `gh pr list` command
- Terminal-based interactive search
- Installation: `gh extension install nogtk/gh-activity`

### 10. gh-stats
**Path:** `submodules/gh-stats`  
**URL:** https://github.com/amitschang/gh-stats  
**Purpose:** Small Rust application to get statistics from GitHub Search API  
**Note:** Minimal documentation

### 11. git-tui-cloner
**Path:** `submodules/git-tui-cloner`  
**URL:** https://github.com/dc-tec/git-tui-cloner  
**Purpose:** TUI (Terminal User Interface) for cloning Git repositories  
**Note:** Work in progress (WIP)

## Cargo & Crates

### 12. cargo-search2
**Path:** `submodules/cargo-search2`  
**URL:** https://github.com/sunshowers/cargo-search2  
**Purpose:** Enhanced version of `cargo search` with better features  
**Key Features:**
- Search for exact versions and semver ranges
- Multiple output formats: plain, JSON, TOML, GitHub Actions
- Cache invalidation support
- Hash generation for cache keys (blake2b24)
- Pre-built binaries available

## Specialized Tools

### 13. project_fibot
**Path:** `submodules/project_fibot`  
**URL:** https://github.com/micheal-ndoh/project_fibot  
**Purpose:** GitHub Action that scans PR text for numbers and calculates Fibonacci  
**Key Features:**
- Scans pull request content for numbers
- Calculates Fibonacci numbers
- Posts results as PR comments
- Configurable: `enable_fib` flag and `max_threshold` parameter
- Written in Rust as a GitHub Action

### 14. search-tinymt-seed-for-web
**Path:** `submodules/search-tinymt-seed-for-web`  
**URL:** https://github.com/RNGeek/search-tinymt-seed-for-web  
**Purpose:** Web port of TinyMT seed search tool  
**Note:** Japanese project - Web移植版 of RNGeek/search-tinymt-seed
**Tech:** Rust + WebAssembly + webpack

### 15. BruteForceDB_Search
**Path:** `submodules/BruteForceDB_Search`  
**URL:** https://github.com/STashakkori/BruteForceDB_Search  
**Purpose:** Recursively search strings against BruteForceDB password database  
**Key Features:**
- Searches passwords against known breach databases
- Helps identify weak passwords
- Works with BruteForceDB from https://github.com/duyet/bruteforce-database

## Reference Collections

### 16. awesome-rust
**Path:** `submodules/awesome-rust`  
**URL:** https://github.com/RustKnowledge/awesome-rust  
**Purpose:** Curated list of awesome Rust resources  
**References:**
- https://github.com/rust-unofficial/awesome-rust
- https://github.com/rust-embedded/awesome-embedded-rust
- https://github.com/rust-in-blockchain/awesome-blockchain-rust

## Technology Stack Summary

### Common Dependencies Across Projects:
- **HTTP Clients:** hyper, reqwest
- **Serialization:** serde, serde_json, bincode
- **Async Runtime:** tokio
- **Web Frameworks:** actix-web, axum
- **CLI:** clap
- **Databases:** RocksDB, SQLite
- **HTML Parsing:** scraper
- **TUI:** Various terminal UI libraries

### Language Distribution:
- **Primary:** Rust
- **Web Frontend:** JavaScript/TypeScript (Next.js, React)
- **Build Tools:** Cargo, npm/yarn, webpack

## Use Cases

1. **Fuzzy Search:** fuse-rust
2. **Full-Text Search:** fulltext-search-rust, search-engine
3. **GitHub Repository Search:** github.alfredworkflow, GitHubSearch, github-search-repository, search-rustyn
4. **GitHub User Profiles:** github-profile
5. **GitHub PR Management:** gh-activity
6. **Cargo Package Search:** cargo-search2
7. **Password Security:** BruteForceDB_Search
8. **GitHub Actions:** project_fibot
9. **CLI Extensions:** gh-activity, gh-stats
10. **TUI Tools:** git-tui-cloner

## Next Steps

To explore specific implementations:
1. Check individual `Cargo.toml` files for dependencies
2. Review `src/` directories for main implementation code
3. Look at examples in projects like fuse-rust and cargo-search2
4. Study API implementations in fulltext-search-rust and search-engine
