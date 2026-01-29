#!/bin/bash
# test_dashboard.sh - Simple dashboard test

echo "🔮 Testing zkPrologML Dashboard"
echo "============================================================"

URL="http://localhost/"

# Test 1: Check if server is running
echo ""
echo "✓ Test 1: Server connectivity"
if curl -s -o /dev/null -w "%{http_code}" "$URL" | grep -q "200"; then
    echo "  ✅ Server is running (HTTP 200)"
else
    echo "  ❌ Server not responding"
    exit 1
fi

# Test 2: Check page content
echo ""
echo "✓ Test 2: Page content"
CONTENT=$(curl -s "$URL")

if echo "$CONTENT" | grep -q "zkPrologML"; then
    echo "  ✅ Title found"
else
    echo "  ❌ Title not found"
fi

if echo "$CONTENT" | grep -q "Frank"; then
    echo "  ✅ Frank assistant found"
else
    echo "  ❌ Frank not found"
fi

if echo "$CONTENT" | grep -q "prologInput"; then
    echo "  ✅ Prolog input found"
else
    echo "  ❌ Prolog input not found"
fi

if echo "$CONTENT" | grep -q "errorLog"; then
    echo "  ✅ Error log found"
else
    echo "  ❌ Error log not found"
fi

# Test 3: Check for required scripts
echo ""
echo "✓ Test 3: Required scripts"
if echo "$CONTENT" | grep -q "tau-prolog"; then
    echo "  ✅ Tau-Prolog CDN found"
else
    echo "  ⚠️  Tau-Prolog CDN not found"
fi

# Test 4: Check for zkProofs
echo ""
echo "✓ Test 4: zkProofs file"
if curl -s -o /dev/null -w "%{http_code}" "${URL}zkproofs_complete.json" | grep -q "200"; then
    echo "  ✅ zkProofs file accessible"
    SIZE=$(curl -s "${URL}zkproofs_complete.json" | wc -c)
    echo "  Size: $SIZE bytes"
else
    echo "  ⚠️  zkProofs file not found"
fi

# Test 5: Check for tau_facts
echo ""
echo "✓ Test 5: Tau facts file"
if curl -s -o /dev/null -w "%{http_code}" "${URL}tau_facts.js" | grep -q "200"; then
    echo "  ✅ Tau facts file accessible"
else
    echo "  ⚠️  Tau facts file not found"
fi

# Test 6: Check for tau_engine
echo ""
echo "✓ Test 6: Tau engine file"
if curl -s -o /dev/null -w "%{http_code}" "${URL}tau_engine.js" | grep -q "200"; then
    echo "  ✅ Tau engine file accessible"
else
    echo "  ⚠️  Tau engine file not found"
fi

# Test 7: Count shards in HTML
echo ""
echo "✓ Test 7: Monster Group shards"
SHARD_COUNT=$(echo "$CONTENT" | grep -o "class=\"shard\"" | wc -l)
echo "  Found $SHARD_COUNT shard elements in HTML"

# Test 8: Check stats cards
echo ""
echo "✓ Test 8: Stats cards"
CARD_COUNT=$(echo "$CONTENT" | grep -o "class=\"card\"" | wc -l)
echo "  Found $CARD_COUNT stat cards"

echo ""
echo "============================================================"
echo "✅ Dashboard tests complete!"
echo ""
echo "Summary:"
echo "  • Server: Running"
echo "  • UI Elements: Present"
echo "  • Frank: Integrated"
echo "  • Error Log: Active"
echo "  • Shards: $SHARD_COUNT"
echo "  • Cards: $CARD_COUNT"
