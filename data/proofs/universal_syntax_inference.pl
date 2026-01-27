% Universal Syntax Inference System
% Use plocate + parquet + reasoning to find and analyze toolchain data

:- dynamic markov_parquet/2.
:- dynamic byte_provenance_parquet/2.
:- dynamic nix_grammar_parquet/2.
:- dynamic toolchain_analyzed/3.

% ═══════════════════════════════════════════════════════════
% PHASE 0: Discover existing data with plocate
% ═══════════════════════════════════════════════════════════

discover_markov_models :-
    write('🔍 Discovering Markov model parquets...'), nl,
    
    shell('plocate -i "markov_symbol_scores.parquet" > markov_files.txt', _),
    
    open('markov_files.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            % Extract toolchain name from path
            (sub_string(Line, _, _, _, '/bash/') -> Tool = bash
            ; sub_string(Line, _, _, _, '/cargo/') -> Tool = cargo
            ; sub_string(Line, _, _, _, '/gcc/') -> Tool = gcc
            ; sub_string(Line, _, _, _, '/rustc/') -> Tool = rustc
            ; Tool = unknown),
            
            assertz(markov_parquet(Tool, Line)),
            format('  Found: ~w -> ~w~n', [Tool, Line])
        )
    ),
    
    write('✅ Markov models discovered'), nl.

discover_byte_provenance :-
    write('🔍 Discovering byte provenance parquets...'), nl,
    
    shell('plocate -i "byte_provenance.parquet" > provenance_files.txt', _),
    
    open('provenance_files.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            (sub_string(Line, _, _, _, '/bash/') -> Tool = bash
            ; sub_string(Line, _, _, _, '/cargo/') -> Tool = cargo
            ; sub_string(Line, _, _, _, '/gcc/') -> Tool = gcc
            ; sub_string(Line, _, _, _, '/rustc/') -> Tool = rustc
            ; Tool = unknown),
            
            assertz(byte_provenance_parquet(Tool, Line)),
            format('  Found: ~w -> ~w~n', [Tool, Line])
        )
    ),
    
    write('✅ Byte provenance discovered'), nl.

discover_nix_grammars :-
    write('🔍 Discovering Nix grammar parquets...'), nl,
    
    shell('plocate -i "nix_store_grammars.parquet" > grammar_files.txt', _),
    
    open('grammar_files.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            (sub_string(Line, _, _, _, '/bash/') -> Tool = bash
            ; sub_string(Line, _, _, _, '/cargo/') -> Tool = cargo
            ; sub_string(Line, _, _, _, '/gcc/') -> Tool = gcc
            ; sub_string(Line, _, _, _, '/rustc/') -> Tool = rustc
            ; Tool = unknown),
            
            assertz(nix_grammar_parquet(Tool, Line)),
            format('  Found: ~w -> ~w~n', [Tool, Line])
        )
    ),
    
    write('✅ Nix grammars discovered'), nl.

% ═══════════════════════════════════════════════════════════
% PHASE 1: Analyze toolchain data
% ═══════════════════════════════════════════════════════════

analyze_toolchain(Tool) :-
    format('~n📊 Analyzing ~w toolchain...~n', [Tool]),
    
    % Check what data we have
    (markov_parquet(Tool, MarkovFile) -> 
        format('  ✓ Markov model: ~w~n', [MarkovFile]),
        HasMarkov = MarkovFile
    ; 
        format('  ✗ No Markov model~n', []),
        HasMarkov = none
    ),
    
    (byte_provenance_parquet(Tool, ProvenanceFile) ->
        format('  ✓ Byte provenance: ~w~n', [ProvenanceFile]),
        HasProvenance = ProvenanceFile
    ;
        format('  ✗ No byte provenance~n', []),
        HasProvenance = none
    ),
    
    (nix_grammar_parquet(Tool, GrammarFile) ->
        format('  ✓ Nix grammar: ~w~n', [GrammarFile])
    ;
        format('  ✗ No Nix grammar~n', [])
    ),
    
    % Mark as analyzed
    assertz(toolchain_analyzed(Tool, 
        has_markov(HasMarkov),
        has_provenance(HasProvenance)
    )).

% ═══════════════════════════════════════════════════════════
% PHASE 2: Reason about syntax inference capability
% ═══════════════════════════════════════════════════════════

can_infer_syntax(Tool) :-
    % Need both Markov model and byte provenance
    markov_parquet(Tool, _),
    byte_provenance_parquet(Tool, _),
    format('✅ ~w: Can infer syntax (has Markov + provenance)~n', [Tool]).

can_infer_syntax(Tool) :-
    \+ markov_parquet(Tool, _),
    format('⚠️  ~w: Cannot infer syntax (missing Markov model)~n', [Tool]).

% ═══════════════════════════════════════════════════════════
% PHASE 3: Generate task list for each toolchain
% ═══════════════════════════════════════════════════════════

generate_tasks(Tool) :-
    format('~n📋 Tasks for ~w:~n', [Tool]),
    
    (markov_parquet(Tool, MarkovFile) ->
        format('  1. Load Markov model from: ~w~n', [MarkovFile])
    ;
        format('  1. Generate Markov model (missing)~n', [])
    ),
    
    (byte_provenance_parquet(Tool, ProvenanceFile) ->
        format('  2. Load byte provenance from: ~w~n', [ProvenanceFile])
    ;
        format('  2. Generate byte provenance (missing)~n', [])
    ),
    
    format('  3. Assign prime complexity to instructions~n', []),
    format('  4. Generate Prolog witness predicates~n', []),
    format('  5. Infer syntax rules from binary~n', []),
    format('  6. Generate DCG parser~n', []),
    format('  7. Verify parser with oracle~n', []),
    format('  8. Export to Lean4~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN DISCOVERY & REASONING
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 UNIVERSAL SYNTAX INFERENCE SYSTEM'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Phase 0: Discover
    discover_markov_models,
    nl,
    discover_byte_provenance,
    nl,
    discover_nix_grammars,
    nl,
    
    % Phase 1: Analyze each toolchain
    findall(T, markov_parquet(T, _), Tools1),
    findall(T, byte_provenance_parquet(T, _), Tools2),
    append(Tools1, Tools2, AllTools),
    list_to_set(AllTools, UniqueTools),
    
    maplist(analyze_toolchain, UniqueTools),
    nl,
    
    % Phase 2: Reason about capabilities
    write('🔬 Syntax Inference Capability:'), nl,
    maplist(can_infer_syntax, UniqueTools),
    nl,
    
    % Phase 3: Generate tasks
    maplist(generate_tasks, UniqueTools),
    nl,
    
    write('✅ DISCOVERY & REASONING COMPLETE'), nl,
    
    % Summary
    length(UniqueTools, Count),
    format('~n🎯 Found ~w toolchains with data~n', [Count]).

% ?- main.
