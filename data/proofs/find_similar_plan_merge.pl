% Find our code using syn, goblin, perf and plan to merge similar patterns
% Self-analysis to consolidate duplicate implementations

:- dynamic code_file/3.
:- dynamic uses_library/3.
:- dynamic merge_candidate/4.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Find code using key libraries
% ═══════════════════════════════════════════════════════════

discover_library_usage :-
    write('🔍 Finding code using syn, goblin, perf...\n\n'),
    
    % Find Rust files using these libraries
    shell('grep -r "use syn" --include="*.rs" . 2>/dev/null | cut -d: -f1 | sort -u > syn_files.txt', _),
    shell('grep -r "use goblin" --include="*.rs" . 2>/dev/null | cut -d: -f1 | sort -u > goblin_files.txt', _),
    shell('grep -r "perf record" --include="*.rs" --include="*.nix" --include="*.sh" . 2>/dev/null | cut -d: -f1 | sort -u > perf_files.txt', _),
    
    % Load syn users
    load_file_list('syn_files.txt', syn),
    load_file_list('goblin_files.txt', goblin),
    load_file_list('perf_files.txt', perf),
    
    % Report
    findall(F, uses_library(F, syn, _), SynFiles),
    findall(F, uses_library(F, goblin, _), GoblinFiles),
    findall(F, uses_library(F, perf, _), PerfFiles),
    
    length(SynFiles, SC),
    length(GoblinFiles, GC),
    length(PerfFiles, PC),
    
    format('✅ syn: ~w files\n', [SC]),
    format('✅ goblin: ~w files\n', [GC]),
    format('✅ perf: ~w files\n\n', [PC]).

load_file_list(File, Library) :-
    (exists_file(File) ->
        (
            open(File, read, S),
            read_string(S, _, Content),
            close(S),
            split_string(Content, "\n", " ", Lines),
            forall(
                (member(L, Lines), L \= ""),
                (
                    assertz(uses_library(L, Library, discovered)),
                    assertz(code_file(L, Library, rust))
                )
            )
        )
    ; true).

% ═══════════════════════════════════════════════════════════
% ANALYZE: Find similar patterns
% ═══════════════════════════════════════════════════════════

analyze_patterns :-
    write('🔬 Analyzing patterns for merging...\n\n'),
    
    % Find files using multiple libraries (high merge value)
    findall(
        (F, Libs),
        (
            code_file(F, _, _),
            findall(L, uses_library(F, L, _), Libs),
            length(Libs, N),
            N > 1
        ),
        MultiLib
    ),
    
    forall(
        member((File, Libraries), MultiLib),
        (
            length(Libraries, Count),
            format('📋 ~w (~w libraries)\n', [File, Count]),
            format('   Uses: ~w\n', [Libraries]),
            assertz(merge_candidate(File, Libraries, Count, high)),
            nl
        )
    ).

% ═══════════════════════════════════════════════════════════
% PLAN: Merge strategy
% ═══════════════════════════════════════════════════════════

plan_merge :-
    write('🎯 Planning merge strategy...\n\n'),
    
    % Group by library combinations
    findall(Libs, merge_candidate(_, Libs, _, _), AllLibs),
    list_to_set(AllLibs, UniqueCombos),
    
    forall(
        member(Combo, UniqueCombos),
        plan_for_combo(Combo)
    ).

plan_for_combo(Libs) :-
    findall(F, merge_candidate(F, Libs, _, _), Files),
    length(Files, Count),
    
    (Count > 1 ->
        (
            format('🔱 Merge opportunity: ~w\n', [Libs]),
            format('   Files: ~w\n', [Count]),
            
            % Suggest merge target
            suggest_merge_target(Libs, Files),
            nl
        )
    ; true).

suggest_merge_target([syn, goblin], Files) :-
    format('   → Merge to: ast_analysis_utils.rs\n', []),
    format('   → Extract: parse_ast/2, analyze_elf/2\n', []),
    forall(member(F, Files), format('     - ~w\n', [F])).

suggest_merge_target([goblin, perf], Files) :-
    format('   → Merge to: binary_perf_analysis.rs\n', []),
    format('   → Extract: trace_binary/2, analyze_symbols/2\n', []),
    forall(member(F, Files), format('     - ~w\n', [F])).

suggest_merge_target([syn, goblin, perf], Files) :-
    format('   → Merge to: full_stack_analysis.rs\n', []),
    format('   → Extract: analyze_source/2, trace_binary/2, measure_perf/2\n', []),
    forall(member(F, Files), format('     - ~w\n', [F])).

suggest_merge_target(Libs, Files) :-
    format('   → Merge to: ~w_utils.rs\n', [Libs]),
    forall(member(F, Files), format('     - ~w\n', [F])).

% ═══════════════════════════════════════════════════════════
% EXECUTE: Generate merge plan
% ═══════════════════════════════════════════════════════════

generate_merge_plan :-
    write('📝 Generating merge plan...\n\n'),
    
    open('MERGE_PLAN.md', write, S),
    
    write(S, '# Code Merge Plan\n\n'),
    write(S, '## Discovered Patterns\n\n'),
    
    findall((F, L, C), merge_candidate(F, L, C, _), Candidates),
    length(Candidates, Total),
    format(S, 'Total merge candidates: ~w\n\n', [Total]),
    
    write(S, '## Merge Targets\n\n'),
    
    % syn + goblin
    findall(F, merge_candidate(F, [syn, goblin], _, _), SynGoblin),
    (SynGoblin \= [] ->
        (
            write(S, '### ast_analysis_utils.rs\n'),
            write(S, 'Merge syn + goblin usage:\n'),
            forall(member(F, SynGoblin), format(S, '- ~w\n', [F])),
            write(S, '\n')
        )
    ; true),
    
    % goblin + perf
    findall(F, merge_candidate(F, [goblin, perf], _, _), GoblinPerf),
    (GoblinPerf \= [] ->
        (
            write(S, '### binary_perf_analysis.rs\n'),
            write(S, 'Merge goblin + perf usage:\n'),
            forall(member(F, GoblinPerf), format(S, '- ~w\n', [F])),
            write(S, '\n')
        )
    ; true),
    
    close(S),
    
    write('✅ Merge plan written to MERGE_PLAN.md\n').

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🔍 FIND SIMILAR CODE → PLAN MERGE\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Discover
    discover_library_usage,
    
    % Analyze
    analyze_patterns,
    
    % Plan
    plan_merge,
    
    % Generate
    generate_merge_plan,
    
    write('\n✅ MERGE PLANNING COMPLETE\n').

% ?- main.
