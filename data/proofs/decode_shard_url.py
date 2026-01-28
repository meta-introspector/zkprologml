#!/usr/bin/env python3
# decode_shard_url.py - Decode compressed shard from URL

import json
import base64
import zlib
import sys
from urllib.parse import urlparse, parse_qs

def decode_url(url: str) -> dict:
    """Decode compressed shard from URL"""
    parsed = urlparse(url)
    params = parse_qs(parsed.query)
    
    prime = int(params['prime'][0])
    count = int(params['count'][0])
    data = params['data'][0]
    
    # Decode base64 and decompress
    compressed = base64.urlsafe_b64decode(data)
    json_data = zlib.decompress(compressed).decode('utf-8')
    entities = json.loads(json_data)
    
    return {
        'prime': prime,
        'count': count,
        'entities': entities
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 decode_shard_url.py <url>")
        print("\nOr test with prime number:")
        print("  python3 decode_shard_url.py 71")
        sys.exit(1)
    
    arg = sys.argv[1]
    
    # If argument is a number, load from 71_urls.json
    if arg.isdigit():
        prime = int(arg)
        with open('generated/71_urls.json', 'r') as f:
            urls = json.load(f)
        url = next((u['url'] for u in urls if u['prime'] == prime), None)
        if not url:
            print(f"❌ No shard for prime {prime}")
            sys.exit(1)
    else:
        url = arg
    
    print(f"🔍 Decoding shard URL...\n")
    
    shard = decode_url(url)
    
    print(f"Prime: {shard['prime']}")
    print(f"Entity count: {shard['count']}")
    print(f"Entities: {len(shard['entities'])}")
    print(f"\n📦 First 3 entities:")
    
    for i, entity in enumerate(shard['entities'][:3]):
        print(f"\n{i+1}. Gödel {entity['godel']}: {entity['path']}")
        print(f"   Type: {entity['type']}")
        print(f"   Primes: {entity['primes']}")
    
    if len(shard['entities']) > 3:
        print(f"\n... and {len(shard['entities']) - 3} more entities")
    
    print(f"\n✅ Shard decoded successfully!")
    print(f"All {shard['count']} entities reconstructed from URL.")

if __name__ == '__main__':
    main()
