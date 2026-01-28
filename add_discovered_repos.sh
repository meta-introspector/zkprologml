#!/bin/bash
echo "🔍 Adding discovered high-value repos as submodules..."

mkdir -p discovered_repos

cd discovered_repos

# crypto-primes - prime number generation
if [ ! -d "crypto-primes" ]; then
    echo "📦 Adding crypto-primes..."
    git submodule add https://github.com/entropyxyz/crypto-primes
fi

# arkworks algebra - finite fields
if [ ! -d "algebra" ]; then
    echo "📦 Adding arkworks algebra..."
    git submodule add https://github.com/arkworks-rs/algebra
fi

# ark-ff specifically
if [ ! -d "ark-ff" ]; then
    echo "📦 Adding ark-ff..."
    git submodule add https://github.com/arkworks-rs/algebra ark-ff
fi

cd ..

echo "✅ Submodules added!"
ls -la discovered_repos/
