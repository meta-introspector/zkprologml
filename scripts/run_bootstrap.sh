#!/usr/bin/env bash
# Bootstrap batch runner - Prolog only, outputs JSON for Rust to convert to parquet

set -euo pipefail

echo "🚀 Running bootstrap in batch mode..."

# Run bootstrap and save JSON
swipl -g "
    [bootstrap],
    bootstrap_self,
    
    % Collect all metrics
    completeness_score(Score),
    self_awareness_level(Level),
    consumed_modules(Modules),
    length(Modules, ModuleCount),
    
    % Collect index cards
    findall([Term, Def, Refs, Chord], 
            index_card(Term, Def, Refs, Chord), 
            Cards),
    length(Cards, CardCount),
    
    % Write JSON
    open('data/parquets/bootstrap_results.json', write, S),
    write(S, '{'),
    format(S, '\"completeness\": ~w,', [Score]),
    format(S, '\"self_awareness\": ~w,', [Level]),
    format(S, '\"module_count\": ~w,', [ModuleCount]),
    format(S, '\"card_count\": ~w,', [CardCount]),
    write(S, '\"cards\": ['),
    forall(
        (index_card(Term, Def, Refs, Chord),
         format(S, '{\"term\":\"~w\",\"definition\":\"~w\",\"references\":~w,\"chord\":~w},', 
                [Term, Def, Refs, Chord])),
        true
    ),
    write(S, '{}]'),
    write(S, '}'),
    close(S),
    
    format('✅ Saved to data/parquets/bootstrap_results.json~n', []),
    halt
" -t halt

echo "✅ Bootstrap complete - converting to parquet with Rust..."

# Convert JSON to parquet with Rust
cargo run --bin bootstrap_to_parquet -- data/parquets/bootstrap_results.json data/parquets/bootstrap.parquet

echo "✅ Results in data/parquets/bootstrap.parquet"
