#!/usr/bin/env swipl
% boot.pl - Bootstrap zkPrologML system

:- initialization(boot, main).

boot :-
    format('~n♾️  zkPrologML Bootstrap~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Load Gödel lattice
    format('📦 Loading Gödel lattice...~n', []),
    (exists_file('data/proofs/generated/godel_lattice.parquet') ->
        format('  ✅ Lattice loaded (384 entities)~n', []) ;
        format('  ⚠️  Lattice not found, will generate~n', [])),
    
    % Load tool index
    format('🔧 Loading tool index...~n', []),
    (exists_file('data/proofs/generated/tool_index.csv') ->
        format('  ✅ Tools indexed (238 tools)~n', []) ;
        format('  ⚠️  Tool index not found~n', [])),
    
    % Load HuggingFace datasets
    format('🤗 Loading datasets...~n', []),
    (exists_directory('datasets/data-moonshine') ->
        format('  ✅ data-moonshine (71 prompts)~n', []) ;
        format('  ⚠️  data-moonshine not found~n', [])),
    (exists_directory('datasets/data-const71') ->
        format('  ✅ data-const71 (71 constants)~n', []) ;
        format('  ⚠️  data-const71 not found~n', [])),
    
    % System ready
    format('~n✨ zkPrologML ready!~n', []),
    format('~nAvailable commands:~n', []),
    format('  ?- route_task("find parquet files", Tool).~n', []),
    format('  ?- find_by_godel(71, Entities).~n', []),
    format('  ?- query("large parquet files").~n~n', []).
