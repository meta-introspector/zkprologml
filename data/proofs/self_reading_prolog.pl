% Self-Reading Prolog: Find duplicate code by reading itself
% Use plocate to find all our Prolog files, then analyze for duplicates

:- dynamic prolog_file/1.
:- dynamic code_pattern/3.
:- dynamic duplicate_found/4.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Find all our Prolog files
% ═══════════════════════════════════════════════════════════

discover_our_prolog :-
    write('🔍 Discovering our Prolog files...'), nl,
    
    % Find all .pl files in our project
    shell('plocate -i "data/proofs" | grep "\\.pl$" > our_prolog_files.txt', _),
    
    open('our_prolog_files.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            assertz(prolog_file(Line)),
            format('  Found: ~w~n', [Line])
        )
    ),
    
    findall(F, prolog_file(F), Files),
    length(Files, Count),
    format('✅ Found ~w Prolog files~n', [Count]).

% ═══════════════════════════════════════════════════════════
% READ: Extract patterns from each file
% ═══════════════════════════════════════════════════════════

read_file_patterns(File) :-
    format('📖 Reading ~w...~n', [File]),
    
    catch(
        (
            open(File, read, Stream),
            read_string(Stream, _, Content),
            close(Stream),
            
            % Extract common patterns
            extract_patterns(File, Content)
        ),
        _,
        format('  ⚠️  Could not read ~w~n', [File])
    ).

extract_patterns(File, Content) :-
    % Pattern 1: shell/2 calls
    (sub_string(Content, _, _, _, "shell(") ->
        assertz(code_pattern(File, shell_call, "shell("))
    ; true),
    
    % Pattern 2: plocate usage
    (sub_string(Content, _, _, _, "plocate") ->
        assertz(code_pattern(File, uses_plocate, "plocate"))
    ; true),
    
    % Pattern 3: parquet operations
    (sub_string(Content, _, _, _, "parquet") ->
        assertz(code_pattern(File, uses_parquet, "parquet"))
    ; true),
    
    % Pattern 4: perf recording
    (sub_string(Content, _, _, _, "perf record") ->
        assertz(code_pattern(File, perf_record, "perf record"))
    ; true),
    
    % Pattern 5: complexity assignment
    (sub_string(Content, _, _, _, "complexity") ->
        assertz(code_pattern(File, uses_complexity, "complexity"))
    ; true),
    
    % Pattern 6: Lean4 export
    (sub_string(Content, _, _, _, ".lean") ->
        assertz(code_pattern(File, exports_lean, ".lean"))
    ; true),
    
    % Pattern 7: Oracle calls
    (sub_string(Content, _, _, _, "oracle") ->
        assertz(code_pattern(File, uses_oracle, "oracle"))
    ; true),
    
    % Pattern 8: Markov models
    (sub_string(Content, _, _, _, "markov") ->
        assertz(code_pattern(File, uses_markov, "markov"))
    ; true).

% ═══════════════════════════════════════════════════════════
% ANALYZE: Find duplicates
% ═══════════════════════════════════════════════════════════

find_duplicates :-
    write('🔬 Finding duplicate patterns...'), nl,
    nl,
    
    % Find files sharing patterns
    findall(Pattern, code_pattern(_, Pattern, _), AllPatterns),
    list_to_set(AllPatterns, UniquePatterns),
    
    forall(
        member(Pattern, UniquePatterns),
        analyze_pattern(Pattern)
    ).

analyze_pattern(Pattern) :-
    findall(File, code_pattern(File, Pattern, _), Files),
    length(Files, Count),
    
    (Count > 1 ->
        (
            format('📋 Pattern "~w" found in ~w files:~n', [Pattern, Count]),
            forall(
                member(File, Files),
                format('  - ~w~n', [File])
            ),
            nl,
            
            % Record as duplicate
            assertz(duplicate_found(Pattern, Files, Count, duplicate))
        )
    ;
        true
    ).

% ═══════════════════════════════════════════════════════════
% REASON: Suggest refactoring
% ═══════════════════════════════════════════════════════════

suggest_refactoring :-
    write('💡 Refactoring suggestions:'), nl,
    nl,
    
    forall(
        duplicate_found(Pattern, Files, Count, _),
        (
            format('Pattern: ~w (~w occurrences)~n', [Pattern, Count]),
            suggest_for_pattern(Pattern, Files),
            nl
        )
    ).

suggest_for_pattern(uses_plocate, Files) :-
    length(Files, Count),
    format('  → Extract to: plocate_utils.pl~n', []),
    format('  → Create: plocate_search/2 predicate~n', []),
    format('  → Saves ~w duplicate implementations~n', [Count]).

suggest_for_pattern(uses_parquet, Files) :-
    length(Files, Count),
    format('  → Extract to: parquet_utils.pl~n', []),
    format('  → Create: load_parquet/2, sample_parquet/3~n', []),
    format('  → Saves ~w duplicate implementations~n', [Count]).

suggest_for_pattern(exports_lean, Files) :-
    length(Files, Count),
    format('  → Extract to: lean_export.pl~n', []),
    format('  → Create: export_proof/2, export_model/2~n', []),
    format('  → Saves ~w duplicate implementations~n', [Count]).

suggest_for_pattern(uses_complexity, Files) :-
    length(Files, Count),
    format('  → Extract to: complexity_lattice.pl~n', []),
    format('  → Create: assign_complexity/3, prime_lattice/1~n', []),
    format('  → Saves ~w duplicate implementations~n', [Count]).

suggest_for_pattern(_, _) :-
    format('  → Consider extracting to shared module~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 SELF-READING PROLOG: FIND DUPLICATES'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Discover
    discover_our_prolog,
    nl,
    
    % Read all files
    findall(F, prolog_file(F), Files),
    maplist(read_file_patterns, Files),
    nl,
    
    % Analyze
    find_duplicates,
    
    % Suggest
    suggest_refactoring,
    
    write('✅ SELF-ANALYSIS COMPLETE'), nl,
    
    % Summary
    findall(D, duplicate_found(_, _, _, _), Dups),
    length(Dups, DupCount),
    format('~n🎯 Found ~w duplicate patterns~n', [DupCount]).

% ?- main.
