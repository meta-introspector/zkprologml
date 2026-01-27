# Bootstrap Escalation Lattice

## Levels of Observation

Each build step is a lattice point with measurements saved to parquet.

### Level 0: rustc (Direct Compilation)
- **Input**: .rs file
- **Tool**: rustc
- **Measurements**: perf stat, strace, CPU temp
- **Output**: Binary + parquet trace
- **Cost**: Decided by DAO

### Level 1: cargo (Build System)
- **Input**: Cargo.toml
- **Tool**: cargo build
- **Measurements**: perf record, build time, dependencies
- **Output**: target/ + parquet trace
- **Cost**: Decided by DAO

### Level 2: nix (Reproducible Build)
- **Input**: .nix derivation
- **Tool**: nix-build
- **Measurements**: Store paths, closure size, build time
- **Output**: /nix/store + parquet trace
- **Cost**: Decided by DAO

### Level 3: syn (AST Parsing)
- **Input**: Rust source
- **Tool**: syn crate
- **Measurements**: Parse time, AST size
- **Output**: Syntax tree + parquet
- **Cost**: Decided by DAO

### Level 4: HIR (High-level IR)
- **Input**: AST
- **Tool**: rustc --emit=hir
- **Measurements**: HIR size, type checking time
- **Output**: HIR dump + parquet
- **Cost**: Decided by DAO

### Level 5: LLVM IR
- **Input**: HIR
- **Tool**: rustc --emit=llvm-ir
- **Measurements**: IR size, optimization passes
- **Output**: .ll file + parquet
- **Cost**: Decided by DAO

### Level 6: objdump (Binary Analysis)
- **Input**: Binary
- **Tool**: objdump -d
- **Measurements**: Code size, instruction count
- **Output**: Disassembly + parquet
- **Cost**: Decided by DAO

### Level 7: goblin (ELF Parsing)
- **Input**: Binary
- **Tool**: goblin crate
- **Measurements**: Sections, symbols, relocations
- **Output**: ELF structure + parquet
- **Cost**: Decided by DAO

### Level 8: perf record (Execution Trace)
- **Input**: Binary
- **Tool**: perf record
- **Measurements**: Cycles, instructions, cache misses
- **Output**: perf.data + parquet
- **Cost**: Decided by DAO

### Level 9: strace (System Calls)
- **Input**: Binary
- **Tool**: strace
- **Measurements**: Syscalls, file access, time
- **Output**: strace.log + parquet
- **Cost**: Decided by DAO

### Level 10: CPU Temperature
- **Input**: Running process
- **Tool**: sensors
- **Measurements**: Temp, power, frequency
- **Output**: Thermal data + parquet
- **Cost**: Decided by DAO

## Bootstrap Chain

### Phase 1: Minimal Bootstrap (GNU Mes)
- mes → tcc → gcc-4.7 → gcc-10 → gcc-13
- Each step: parquet trace
- Cost: DAO decides resource allocation

### Phase 2: Compiler Bootstrap (GCC)
- gcc → binutils → glibc → gcc (self-hosted)
- Each step: parquet trace
- Cost: DAO decides

### Phase 3: LLVM Bootstrap
- gcc → cmake → llvm → clang
- Each step: parquet trace
- Cost: DAO decides

### Phase 4: Rust Bootstrap
- llvm → rustc stage0 → stage1 → stage2
- Each step: parquet trace
- Cost: DAO decides

### Phase 5: Nix Bootstrap
- gcc → nix → nixpkgs
- Each step: parquet trace
- Cost: DAO decides

### Phase 6: Linux Bootstrap
- gcc → kernel → modules → initrd
- Each step: parquet trace
- Cost: DAO decides

## Lattice Structure

```
Z₀₋₇₁ × Bootstrap_Level × Tool × Measurement
```

Each point (z, b, t, m) stores:
- Complexity level z ∈ [0..71]
- Bootstrap level b ∈ [0..10]
- Tool t ∈ {rustc, cargo, nix, ...}
- Measurement m ∈ {perf, strace, temp, ...}
- Cost (decided by DAO)
- Result (parquet)

## DAO Decision Making

For each step:
1. Estimate cost (CPU, memory, time)
2. Check budget
3. Decide: execute or skip
4. Record decision + rationale
5. Save to parquet

## Parquet Schema

```
- complexity_level: u8 [0..71]
- bootstrap_level: u8 [0..10]
- tool: string
- measurement: string
- cost_estimate: u64
- cost_actual: u64
- dao_decision: bool
- dao_rationale: string
- result_data: binary (compressed)
- timestamp: timestamp
```

## The Plan Becomes the Shape

Each execution creates a lattice point.
The collection of points forms the project shape.
The shape maps to LMFDB structures.
The system learns optimal paths through the lattice.

**The bootstrap IS the ontology.**
