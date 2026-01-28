% Extract keywords from high-value projects to find similar data
% Learn what makes projects valuable, then find more like them

:- dynamic keyword/3.
:- dynamic project/2.
:- dynamic similar_found/3.

% ═══════════════════════════════════════════════════════════
% HIGH VALUE PROJECTS: What we've built
% ═══════════════════════════════════════════════════════════

high_value_projects([
    'zkPrologML',
    'meta-introspector',
    'zombie_driver2',
    'zos-server',
    'monster',
    'CompCert',
    'MetaCoq',
    'LMFDB'
]).

% ═══════════════════════════════════════════════════════════
% EXTRACT: Keywords from our projects
% ═══════════════════════════════════════════════════════════

extract_keywords :-
    write('🔍 Extracting keywords from high-value projects...\n\n'),
    
    % Keywords from our work
    Keywords = [
        (monster, high, 'Monster group'),
        (prime, high, 'Prime numbers'),
        (complexity, high, 'Complexity lattice'),
        (prolog, high, 'Prolog code'),
        (lean, high, 'Lean4 proofs'),
        (coq, high, 'Coq proofs'),
        (rust, high, 'Rust code'),
        (perf, high, 'Performance tracing'),
        (lattice, high, 'Lattice structures'),
        (bott, high, 'Bott periodicity'),
        (galois, medium, 'Galois theory'),
        (oracle, medium, 'Oracle bridge'),
        (parquet, medium, 'Parquet data'),
        (goblin, medium, 'ELF parsing'),
        (compiler, medium, 'Compiler theory'),
        (kernel, medium, 'Kernel code'),
        (automorphic, medium, 'Automorphic forms'),
        (genus, medium, 'Genus classification'),
        (lmfdb, high, 'LMFDB database'),
        (ziggurat, medium, 'Ziggurat tower')
    ],
    
    forall(
        member((K, Priority, Desc), Keywords),
        (
            assertz(keyword(K, Priority, Desc)),
            format('  ~w (~w): ~w\n', [K, Priority, Desc])
        )
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% SEARCH: Find data matching our keywords
% ═══════════════════════════════════════════════════════════

search_for_similar :-
    write('🔎 Searching for similar data...\n\n'),
    
    % Search high priority keywords first
    findall(K, keyword(K, high, _), HighKeywords),
    
    forall(
        member(K, HighKeywords),
        search_keyword(K)
    ).

search_keyword(Keyword) :-
    format('📋 Searching: ~w\n', [Keyword]),
    
    % Use plocate to find files
    format(string(Cmd), 'plocate -i "~w" | grep -E "\\.(rs|pl|lean|v|nix|sh)$" | head -20', [Keyword]),
    shell(Cmd, _),
    
    nl.

% ═══════════════════════════════════════════════════════════
% ANALYZE: Check if found files are valuable
% ═══════════════════════════════════════════════════════════

analyze_found_files :-
    write('🔬 Analyzing found files for value...\n\n'),
    
    % Collect files from search
    shell('plocate -i "monster" | grep -E "\\.(rs|pl|lean)$" | head -50 > found_files.txt', _),
    
    open('found_files.txt', read, S),
    read_string(S, _, Content),
    close(S),
    split_string(Content, "\n", " ", Files),
    
    length(Files, Total),
    format('Found ~w files to analyze\n\n', [Total]),
    
    % Score each file
    forall(
        (member(F, Files), F \= ""),
        score_file(F)
    ).

score_file(File) :-
    Score is 0,
    
    % Check for multiple keywords
    findall(K, (keyword(K, _, _), sub_string(File, _, _, _, K)), Matches),
    length(Matches, MatchCount),
    
    (MatchCount > 2 ->
        (
            format('✅ HIGH VALUE: ~w (~w keywords)\n', [File, MatchCount]),
            assertz(similar_found(File, high, Matches))
        )
    ; MatchCount > 0 ->
        format('  Medium: ~w (~w keywords)\n', [File, MatchCount])
    ;
        true
    ).

% ═══════════════════════════════════════════════════════════
% INGEST: High-value similar files
% ═══════════════════════════════════════════════════════════

ingest_similar :-
    write('\n🔱 Ingesting high-value similar files...\n\n'),
    
    findall(F, similar_found(F, high, _), HighValue),
    length(HighValue, Count),
    format('Found ~w high-value files\n\n', [Count]),
    
    forall(
        similar_found(File, high, Keywords),
        (
            format('📊 ~w\n', [File]),
            format('   Keywords: ~w\n\n', [Keywords])
        )
    ).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🌟 EXTRACT KEYWORDS → FIND SIMILAR DATA\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Extract keywords from our work
    extract_keywords,
    
    % Search for similar
    search_for_similar,
    
    % Analyze what we found
    analyze_found_files,
    
    % Ingest high-value
    ingest_similar,
    
    write('✅ KEYWORD EXTRACTION COMPLETE\n').

% ?- main.
