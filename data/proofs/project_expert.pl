% Project Structure Expert System
% Reason about code, detect duplicates, learn patterns

% ═══════════════════════════════════════════════════════════
% PART 1: Index All Code Files
% ═══════════════════════════════════════════════════════════

% Scan directory and index all files
index_project(Root) :-
    retractall(file_indexed(_, _, _)),
    retractall(function_defined(_, _, _)),
    retractall(duplicate_code(_, _, _)),
    
    write('📂 Indexing project...'), nl,
    index_directory(Root),
    
    write('✅ Indexing complete'), nl,
    
    % Analyze
    analyze_duplicates,
    analyze_patterns,
    generate_report.

% Recursively index directory
index_directory(Dir) :-
    exists_directory(Dir),
    directory_files(Dir, Files),
    forall(
        (member(File, Files), 
         File \= '.', 
         File \= '..'),
        process_file(Dir, File)
    ).

process_file(Dir, File) :-
    atomic_list_concat([Dir, '/', File], Path),
    (   exists_directory(Path)
    ->  index_directory(Path)
    ;   index_file(Path)
    ).

% Index individual file
index_file(Path) :-
    file_name_extension(_, Ext, Path),
    member(Ext, [rs, pl, hs, lean, v, nix, mzn]),
    !,
    read_file_to_string(Path, Content, []),
    string_length(Content, Size),
    hash_term(Content, Hash),
    assertz(file_indexed(Path, Ext, hash(Hash, Size))),
    extract_functions(Path, Ext, Content).

index_file(_).  % Skip non-code files

% ═══════════════════════════════════════════════════════════
% PART 2: Extract Functions/Predicates
% ═══════════════════════════════════════════════════════════

extract_functions(Path, rs, Content) :-
    % Extract Rust functions
    findall(Func,
            (sub_string(Content, _, _, _, "fn "),
             extract_rust_function(Content, Func)),
            Functions),
    forall(member(F, Functions),
           assertz(function_defined(Path, rust, F))).

extract_functions(Path, pl, Content) :-
    % Extract Prolog predicates
    findall(Pred,
            (sub_string(Content, _, _, _, ":-"),
             extract_prolog_predicate(Content, Pred)),
            Predicates),
    forall(member(P, Predicates),
           assertz(function_defined(Path, prolog, P))).

extract_functions(Path, hs, Content) :-
    % Extract Haskell functions
    findall(Func,
            extract_haskell_function(Content, Func),
            Functions),
    forall(member(F, Functions),
           assertz(function_defined(Path, haskell, F))).

extract_functions(_, _, _).  % Default: no extraction

% Simplified extractors
extract_rust_function(Content, Func) :-
    sub_string(Content, Start, _, _, "fn "),
    sub_string(Content, Start, 100, _, Snippet),
    split_string(Snippet, "(", "", [FnPart|_]),
    split_string(FnPart, " ", "", Parts),
    last(Parts, Func).

extract_prolog_predicate(Content, Pred) :-
    sub_string(Content, Start, _, _, ":-"),
    sub_string(Content, 0, Start, _, Before),
    split_string(Before, "\n", "", Lines),
    last(Lines, LastLine),
    split_string(LastLine, "(", "", [Pred|_]).

extract_haskell_function(Content, Func) :-
    sub_string(Content, _, _, _, "::"),
    sub_string(Content, Start, 100, _, Snippet),
    split_string(Snippet, " ", "", [Func|_]).

% ═══════════════════════════════════════════════════════════
% PART 3: Detect Duplicates
% ═══════════════════════════════════════════════════════════

analyze_duplicates :-
    write('🔍 Analyzing duplicates...'), nl,
    
    % Find files with same hash
    findall([Path1, Path2],
            (file_indexed(Path1, _, hash(H, _)),
             file_indexed(Path2, _, hash(H, _)),
             Path1 @< Path2),
            ExactDuplicates),
    
    length(ExactDuplicates, NumExact),
    format('  Exact duplicates: ~w~n', [NumExact]),
    
    % Find similar functions
    findall([Func, Path1, Path2],
            (function_defined(Path1, _, Func),
             function_defined(Path2, _, Func),
             Path1 @< Path2),
            FuncDuplicates),
    
    length(FuncDuplicates, NumFunc),
    format('  Duplicate functions: ~w~n', [NumFunc]),
    
    % Store duplicates
    forall(member([P1, P2], ExactDuplicates),
           assertz(duplicate_code(exact, P1, P2))),
    forall(member([F, P1, P2], FuncDuplicates),
           assertz(duplicate_code(function(F), P1, P2))).

% ═══════════════════════════════════════════════════════════
% PART 4: Pattern Analysis
% ═══════════════════════════════════════════════════════════

analyze_patterns :-
    write('🔬 Analyzing patterns...'), nl,
    
    % Count perf-related code
    findall(Path,
            (file_indexed(Path, _, _),
             read_file_to_string(Path, Content, []),
             sub_string(Content, _, _, _, "perf")),
            PerfFiles),
    length(PerfFiles, NumPerf),
    format('  Files using perf: ~w~n', [NumPerf]),
    assertz(pattern(perf_usage, NumPerf, PerfFiles)),
    
    % Count complexity measurement
    findall(Path,
            (file_indexed(Path, _, _),
             read_file_to_string(Path, Content, []),
             (sub_string(Content, _, _, _, "complexity") ;
              sub_string(Content, _, _, _, "Complexity"))),
            ComplexityFiles),
    length(ComplexityFiles, NumComplexity),
    format('  Files measuring complexity: ~w~n', [NumComplexity]),
    assertz(pattern(complexity_measurement, NumComplexity, ComplexityFiles)),
    
    % Count ZK proofs
    findall(Path,
            (file_indexed(Path, _, _),
             read_file_to_string(Path, Content, []),
             (sub_string(Content, _, _, _, "zk_proof") ;
              sub_string(Content, _, _, _, "ZK"))),
            ZKFiles),
    length(ZKFiles, NumZK),
    format('  Files with ZK proofs: ~w~n', [NumZK]),
    assertz(pattern(zk_proofs, NumZK, ZKFiles)).

% ═══════════════════════════════════════════════════════════
% PART 5: Expert System Rules
% ═══════════════════════════════════════════════════════════

% Rule: Suggest refactoring if too many duplicates
suggest_refactoring :-
    findall(1, duplicate_code(function(_), _, _), Dups),
    length(Dups, N),
    N > 5,
    !,
    write('💡 SUGGESTION: Refactor duplicate functions into shared module'), nl.
suggest_refactoring.

% Rule: Suggest consolidation if multiple perf implementations
suggest_consolidation :-
    pattern(perf_usage, N, _),
    N > 3,
    !,
    write('💡 SUGGESTION: Consolidate perf tracing into single module'), nl.
suggest_consolidation.

% Rule: Detect missing documentation
check_documentation :-
    findall(Path,
            (file_indexed(Path, rs, _),
             \+ has_documentation(Path)),
            Undocumented),
    length(Undocumented, N),
    (   N > 0
    ->  format('⚠️  WARNING: ~w Rust files lack documentation~n', [N])
    ;   true
    ).

has_documentation(Path) :-
    read_file_to_string(Path, Content, []),
    (sub_string(Content, _, _, _, "///") ;
     sub_string(Content, _, _, _, "//!")).

% ═══════════════════════════════════════════════════════════
% PART 6: Learning System
% ═══════════════════════════════════════════════════════════

% Learn project structure
learn_structure :-
    write('🧠 Learning project structure...'), nl,
    
    % Learn file organization
    findall(Dir,
            (file_indexed(Path, _, _),
             file_directory_name(Path, Dir)),
            Dirs),
    sort(Dirs, UniqueDirs),
    length(UniqueDirs, NumDirs),
    format('  Directories: ~w~n', [NumDirs]),
    assertz(learned(directory_count, NumDirs)),
    
    % Learn language distribution
    findall(Ext,
            file_indexed(_, Ext, _),
            Extensions),
    msort(Extensions, SortedExts),
    clumped(SortedExts, Clumped),
    format('  Language distribution:~n', []),
    forall(member(Ext-Count, Clumped),
           (format('    ~w: ~w files~n', [Ext, Count]),
            assertz(learned(language(Ext), Count)))),
    
    % Learn common patterns
    learn_common_patterns.

learn_common_patterns :-
    % Find most common function names
    findall(Func,
            function_defined(_, _, Func),
            AllFuncs),
    msort(AllFuncs, Sorted),
    clumped(Sorted, Clumped),
    sort(2, @>=, Clumped, ByCount),
    take(5, ByCount, TopFuncs),
    format('  Most common functions:~n', []),
    forall(member(Func-Count, TopFuncs),
           (format('    ~w: ~w occurrences~n', [Func, Count]),
            assertz(learned(common_function(Func), Count)))).

take(N, List, Taken) :-
    length(Taken, N),
    append(Taken, _, List),
    !.
take(_, List, List).

% ═══════════════════════════════════════════════════════════
% PART 7: Generate Report
% ═══════════════════════════════════════════════════════════

generate_report :-
    write(''), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    write('PROJECT ANALYSIS REPORT'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Summary
    findall(1, file_indexed(_, _, _), Files),
    length(Files, NumFiles),
    format('Total files indexed: ~w~n', [NumFiles]),
    nl,
    
    % Duplicates
    findall(1, duplicate_code(exact, _, _), ExactDups),
    length(ExactDups, NumExact),
    format('Exact duplicates: ~w~n', [NumExact]),
    
    findall(1, duplicate_code(function(_), _, _), FuncDups),
    length(FuncDups, NumFunc),
    format('Duplicate functions: ~w~n', [NumFunc]),
    nl,
    
    % Patterns
    write('Patterns detected:'), nl,
    forall(pattern(Name, Count, _),
           format('  ~w: ~w~n', [Name, Count])),
    nl,
    
    % Suggestions
    write('Expert System Suggestions:'), nl,
    suggest_refactoring,
    suggest_consolidation,
    check_documentation,
    nl,
    
    % Learning
    learn_structure,
    nl,
    
    write('═══════════════════════════════════════════════════════════'), nl,
    write('QED ∎'), nl.

% ═══════════════════════════════════════════════════════════
% PART 8: Save Knowledge Base
% ═══════════════════════════════════════════════════════════

save_knowledge_base(File) :-
    open(File, write, Stream),
    
    write(Stream, '% Project Knowledge Base\n'),
    write(Stream, '% Generated by Expert System\n\n'),
    
    % Save indexed files
    write(Stream, '% Indexed Files\n'),
    forall(file_indexed(Path, Ext, Hash),
           format(Stream, 'file_indexed(~q, ~q, ~q).~n', [Path, Ext, Hash])),
    
    write(Stream, '\n% Functions\n'),
    forall(function_defined(Path, Lang, Func),
           format(Stream, 'function_defined(~q, ~q, ~q).~n', [Path, Lang, Func])),
    
    write(Stream, '\n% Duplicates\n'),
    forall(duplicate_code(Type, P1, P2),
           format(Stream, 'duplicate_code(~q, ~q, ~q).~n', [Type, P1, P2])),
    
    write(Stream, '\n% Patterns\n'),
    forall(pattern(Name, Count, Files),
           format(Stream, 'pattern(~q, ~w, ~q).~n', [Name, Count, Files])),
    
    write(Stream, '\n% Learned Knowledge\n'),
    forall(learned(Fact, Value),
           format(Stream, 'learned(~q, ~w).~n', [Fact, Value])),
    
    close(Stream),
    format('✅ Knowledge base saved to: ~w~n', [File]).

% ═══════════════════════════════════════════════════════════
% PART 9: Query Interface
% ═══════════════════════════════════════════════════════════

% Find all files using a pattern
find_files_with(Pattern, Files) :-
    findall(Path,
            (file_indexed(Path, _, _),
             read_file_to_string(Path, Content, []),
             sub_string(Content, _, _, _, Pattern)),
            Files).

% Find duplicate implementations
find_duplicate_implementations(Function, Paths) :-
    findall(Path,
            function_defined(Path, _, Function),
            Paths),
    length(Paths, N),
    N > 1.

% Recommend refactoring
recommend_refactoring(Recommendations) :-
    findall(refactor(Func, Paths),
            (find_duplicate_implementations(Func, Paths),
             length(Paths, N),
             N > 2),
            Recommendations).

% ═══════════════════════════════════════════════════════════
% MAIN ENTRY POINT
% ═══════════════════════════════════════════════════════════

main :-
    write('🤖 Project Structure Expert System'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Index current directory
    working_directory(CWD, CWD),
    index_project(CWD),
    
    % Save knowledge
    save_knowledge_base('data/proofs/project_knowledge.pl'),
    
    nl,
    write('Expert system ready. Use queries like:'), nl,
    write('  ?- find_files_with("perf", Files).'), nl,
    write('  ?- find_duplicate_implementations("factorial", Paths).'), nl,
    write('  ?- recommend_refactoring(R).'), nl.

% ═══════════════════════════════════════════════════════════
% QUERIES
% ═══════════════════════════════════════════════════════════

% ?- main.
% ?- find_files_with("perf", Files).
% ?- recommend_refactoring(R).

% ═══════════════════════════════════════════════════════════
% END OF EXPERT SYSTEM
% ═══════════════════════════════════════════════════════════
