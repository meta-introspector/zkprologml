% Oracle: Find Rust parquet reader in filesystem

:- dynamic rust_parquet_tool/2.

% ═══════════════════════════════════════════════════════════
% ORACLE: Find Rust Parquet Reader
% ═══════════════════════════════════════════════════════════

oracle_find_parquet_reader :-
    write('🔍 Oracle searching for Rust parquet readers...'), nl,
    nl,
    
    % Strategy 1: Find parquet binaries
    write('Strategy 1: plocate parquet binaries'), nl,
    shell('plocate -b parquet | grep -E "(bin/|target/release/)" | head -20', Binaries),
    write(Binaries), nl,
    
    % Strategy 2: Find Cargo.toml with parquet deps
    write('Strategy 2: Find Cargo.toml with parquet'), nl,
    shell('plocate Cargo.toml | xargs grep -l "parquet" 2>/dev/null | head -10', Cargos),
    write(Cargos), nl,
    
    % Strategy 3: Find .rs files with parquet
    write('Strategy 3: Find .rs with parquet imports'), nl,
    shell('plocate -r ".*\\.rs$" | xargs grep -l "use.*parquet" 2>/dev/null | head -10', RustFiles),
    write(RustFiles), nl,
    
    % Strategy 4: Check if parquet-tools exists
    write('Strategy 4: Check for parquet-tools'), nl,
    (shell('which parquet-tools 2>/dev/null', ParquetTools) ->
        format('Found: ~w~n', [ParquetTools])
    ;
        write('Not found in PATH'), nl
    ),
    
    % Strategy 5: Check cargo install list
    write('Strategy 5: Check cargo installed tools'), nl,
    shell('ls ~/.cargo/bin/ 2>/dev/null | grep -i parquet', CargoTools),
    write(CargoTools), nl.

% ═══════════════════════════════════════════════════════════
% ORACLE: Use Found Reader
% ═══════════════════════════════════════════════════════════

oracle_read_parquet(ParquetFile) :-
    write('🔍 Oracle reading parquet file...'), nl,
    format('File: ~w~n', [ParquetFile]),
    nl,
    
    % Try multiple strategies
    (oracle_read_with_python(ParquetFile) -> true
    ; oracle_read_with_rust(ParquetFile) -> true
    ; oracle_read_with_parquet_tools(ParquetFile) -> true
    ; write('❌ No parquet reader found'), nl
    ).

% Strategy 1: Python + pyarrow
oracle_read_with_python(File) :-
    write('Trying: python + pyarrow'), nl,
    format(atom(Cmd), 'python3 -c "import pyarrow.parquet as pq; t=pq.read_table(\'~w\'); print(t.schema); print(t.to_pandas().head())" 2>/dev/null', [File]),
    shell(Cmd, Output),
    Output \= "",
    write(Output), nl,
    write('✅ Success with python'), nl.

% Strategy 2: Rust parquet-tools
oracle_read_with_rust(File) :-
    write('Trying: Rust parquet reader'), nl,
    % Look for our own tools
    (exists_file('parquet_prolog') ->
        format(atom(Cmd), './parquet_prolog ~w', [File])
    ; exists_file('target/release/parquet_prolog') ->
        format(atom(Cmd), './target/release/parquet_prolog ~w', [File])
    ; fail
    ),
    shell(Cmd, Output),
    write(Output), nl,
    write('✅ Success with Rust'), nl.

% Strategy 3: parquet-tools
oracle_read_with_parquet_tools(File) :-
    write('Trying: parquet-tools'), nl,
    format(atom(Cmd), 'parquet-tools schema ~w 2>/dev/null', [File]),
    shell(Cmd, Output),
    Output \= "",
    write(Output), nl,
    write('✅ Success with parquet-tools'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE PARQUET READER FINDER'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    oracle_find_parquet_reader,
    nl,
    
    write('═══════════════════════════════════════════════════════════'), nl,
    write('Testing with repo_database.parquet'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    oracle_read_parquet('/home/mdupont/nix-controller/data/repo_database.parquet').

% ?- main.
