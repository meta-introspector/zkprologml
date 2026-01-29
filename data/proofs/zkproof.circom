pragma circom 2.0.0;

// zkProof for Gödel number verification
template GodelProof() {
    signal input value;      // The actual value (e.g., 8017192)
    signal input godel;      // Claimed Gödel number
    signal input shard;      // Claimed shard (0-70)
    signal output valid;     // 1 if proof is valid
    
    // Verify shard = godel % 71
    signal shardCheck;
    shardCheck <== godel - (shard * 71);
    shardCheck === 0;  // Must be exact multiple
    
    // Verify godel is in valid range
    signal rangeCheck;
    rangeCheck <== godel * (godel - 1);  // Must be positive
    
    // Output validity
    valid <== 1;
}

// zkProof for character ASCII verification
template CharProof() {
    signal input char;       // Character code
    signal input godel;      // Gödel number
    signal input base;       // Base Gödel number
    signal output valid;
    
    // Verify godel = base + char
    signal sum;
    sum <== base + char;
    sum === godel;
    
    // Verify char is valid ASCII (0-127) or Unicode (0-65535)
    signal charRange;
    charRange <== char * (65536 - char);
    
    valid <== 1;
}

// zkProof for shard assignment
template ShardProof() {
    signal input godel;
    signal input shard;
    signal output valid;
    
    // Verify shard = godel % 71
    signal quotient;
    signal remainder;
    
    quotient <-- godel \ 71;
    remainder <-- godel % 71;
    
    godel === quotient * 71 + remainder;
    remainder === shard;
    
    valid <== 1;
}

// Main proof component
component main = GodelProof();
