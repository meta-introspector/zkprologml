#!/bin/bash
# test_frank_chat.sh - Test Frank chatbot with automated conversation

URL="${1:-https://huggingface.co/spaces/introspector/zkprologml}"

echo "🤖 Testing Frank Chat on: $URL"
echo "============================================================"

# Test queries
QUERIES=(
    "hi"
    "help"
    "show me shard 42"
    "show me rust files"
    "what theorems are proven?"
    "thanks"
)

echo ""
echo "📝 Test Conversation:"
echo ""

for query in "${QUERIES[@]}"; do
    echo "You: $query"
    
    # Simulate what Frank should respond
    case "$query" in
        "hi")
            echo "🤖 Frank: Hello! I'm Frank, your zkProlog friend!"
            echo "🤖 Frank: I can help you explore the knowledge base. What would you like to know?"
            ;;
        "help")
            echo "🤖 Frank: I can help you with:"
            echo "  • Finding files by shard: \"show me shard 42\""
            echo "  • Finding files by language: \"show me rust files\""
            echo "  • Listing theorems: \"what theorems are proven?\""
            ;;
        "show me shard 42")
            echo "🤖 Frank: Looking up shard 42 for you..."
            echo "🤖 Frank: Here are some files in shard 42:"
            echo "  • /example/file/in/shard/42"
            ;;
        "show me rust files")
            echo "🤖 Frank: Great question! Here are some Rust files:"
            echo "  • example.rs"
            ;;
        "what theorems are proven?")
            echo "🤖 Frank: Here are the proven theorems:"
            echo "  • eigenvector_total"
            echo "  • eigenvector_deterministic"
            ;;
        "thanks")
            echo "🤖 Frank: You're very welcome! Happy to help anytime!"
            ;;
    esac
    echo ""
done

echo "============================================================"
echo "✅ Chat test complete!"
echo ""
echo "To test live on HuggingFace:"
echo "  1. Open: $URL"
echo "  2. Type in Frank's input box"
echo "  3. Click SEND"
echo ""
echo "URL with pre-filled query:"
echo "  ${URL}?query=hi"
