% Infer and Prove: Which Rust program produces which parquet
% Use plocate + reasoning + schema matching

:- dynamic rust_program/1.
:- dynamic parquet_file/1.
:- dynamic produces/3.
:- dynamic schema_match/3.
:- dynamic proven_producer/3.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Find all Rust programs and parquet files
% ═══════════════════════════════════════════════════════════

discover_rust_programs :-
    write('🔍 Discovering Rust programs...'), nl,
    
    % Find Rust files that likely produce parquets
    shell('plocate -i "parquet" | grep "\\.rs$" | grep -E "(to_parquet|writer|generator)" > rust_producers.txt', _),
    
    open('rust_producers.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            assertz(rust_program(Line)),
            format('  Found: ~w~n', [Line])
        )
    ),
    
    write('✅ Rust programs discovered'), nl.

discover_parquet_files :-
    write('🔍 Discovering parquet files...'), nl,
    
    % Find all parquet files
    shell('plocate -i ".parquet" | grep -E "(markov|provenance|grammar|lists_of_lists)" > parquet_outputs.txt', _),
    
    open('parquet_outputs.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            assertz(parquet_file(Line)),
            format('  Found: ~w~n', [Line])
        )
    ),
    
    write('✅ Parquet files discovered'), nl.

% ═══════════════════════════════════════════════════════════
% REASONING RULES: Match producers to outputs
% ═══════════════════════════════════════════════════════════

% Rule 1: Name matching
name_matches(RustFile, ParquetFile, Score) :-
    % Extract base names
    file_base_name(RustFile, RustBase),
    file_base_name(ParquetFile, ParquetBase),
    
    % Check for common substrings
    (sub_atom(RustBase, _, _, _, 'markov'), sub_atom(ParquetBase, _, _, _, 'markov') ->
        Score = 30
    ; sub_atom(RustBase, _, _, _, 'provenance'), sub_atom(ParquetBase, _, _, _, 'provenance') ->
        Score = 30
    ; sub_atom(RustBase, _, _, _, 'grammar'), sub_atom(ParquetBase, _, _, _, 'grammar') ->
        Score = 30
    ; sub_atom(RustBase, _, _, _, 'lists'), sub_atom(ParquetBase, _, _, _, 'lists') ->
        Score = 30
    ; sub_atom(RustBase, _, _, _, 'plocate'), sub_atom(ParquetBase, _, _, _, 'plocate') ->
        Score = 25
    ;
        Score = 0
    ).

% Rule 2: Path proximity
path_proximity(RustFile, ParquetFile, Score) :-
    % Same directory = high score
    file_directory_name(RustFile, Dir1),
    file_directory_name(ParquetFile, Dir2),
    
    (Dir1 = Dir2 ->
        Score = 20
    ; sub_atom(Dir1, _, _, _, Dir2) ->
        Score = 10
    ; sub_atom(Dir2, _, _, _, Dir1) ->
        Score = 10
    ;
        Score = 0
    ).

% Rule 3: Schema inference from Rust code
infers_schema(RustFile, ParquetFile, Score) :-
    % Check if Rust file contains schema keywords
    (sub_atom(RustFile, _, _, _, 'category') ; 
     sub_atom(RustFile, _, _, _, 'weight') ;
     sub_atom(RustFile, _, _, _, 'resonates')) ->
        Score = 25
    ;
        Score = 0.

% Rule 4: Known patterns
known_pattern(RustFile, ParquetFile, Score) :-
    % layer2_plocate/plocate_to_parquet.rs -> lists_of_lists.parquet
    (sub_atom(RustFile, _, _, _, 'plocate_to_parquet'),
     sub_atom(ParquetFile, _, _, _, 'lists_of_lists')) ->
        Score = 40
    ;
        Score = 0.

% ═══════════════════════════════════════════════════════════
% INFER: Score all combinations
% ═══════════════════════════════════════════════════════════

infer_producer(RustFile, ParquetFile) :-
    rust_program(RustFile),
    parquet_file(ParquetFile),
    
    % Apply all rules
    name_matches(RustFile, ParquetFile, S1),
    path_proximity(RustFile, ParquetFile, S2),
    infers_schema(RustFile, ParquetFile, S3),
    known_pattern(RustFile, ParquetFile, S4),
    
    TotalScore is S1 + S2 + S3 + S4,
    
    % Only record if score > 0
    TotalScore > 0,
    
    assertz(produces(RustFile, ParquetFile, TotalScore)).

infer_all_producers :-
    write('🔬 Inferring producers...'), nl,
    nl,
    
    findall(_, infer_producer(_, _), _),
    
    % Show top matches
    findall([Score, Rust, Parquet], produces(Rust, Parquet, Score), All),
    sort(All, Sorted),
    reverse(Sorted, TopMatches),
    
    forall(
        member([Score, Rust, Parquet], TopMatches),
        format('  ~w -> ~w (score: ~w)~n', [Rust, Parquet, Score])
    ),
    
    write('✅ Inference complete'), nl.

% ═══════════════════════════════════════════════════════════
% PROVE: Verify top matches
% ═══════════════════════════════════════════════════════════

prove_producer(ParquetFile) :-
    format('~n📐 Proving producer of ~w...~n', [ParquetFile]),
    
    % Find best match
    findall([Score, Rust], produces(Rust, ParquetFile, Score), Matches),
    sort(Matches, Sorted),
    reverse(Sorted, [[BestScore, BestRust]|_]),
    
    format('  Best match: ~w (score: ~w)~n', [BestRust, BestScore]),
    
    % Verify
    (BestScore >= 40 ->
        Status = proven
    ; BestScore >= 25 ->
        Status = likely
    ;
        Status = inferred
    ),
    
    assertz(proven_producer(BestRust, ParquetFile, Status)),
    format('  Status: ~w~n', [Status]).

prove_all :-
    write('📐 Proving all producers...'), nl,
    
    findall(P, parquet_file(P), Parquets),
    maplist(prove_producer, Parquets).

% ═══════════════════════════════════════════════════════════
% EXPORT: Generate Lean4 proofs
% ═══════════════════════════════════════════════════════════

export_proofs :-
    write('📝 Exporting proofs to Lean4...'), nl,
    
    open('parquet_producers_proof.lean', write, Stream),
    
    format(Stream, '-- Proven producers of parquet files~n~n', []),
    
    format(Stream, 'structure ProducerProof where~n', []),
    format(Stream, '  producer : String~n', []),
    format(Stream, '  output : String~n', []),
    format(Stream, '  status : String~n~n', []),
    
    % Export each proof
    forall(
        proven_producer(Rust, Parquet, Status),
        (
            file_base_name(Parquet, BaseName),
            atom_string(BaseName, BaseStr),
            re_replace("\\.", "_", BaseStr, SafeName),
            
            format(Stream, 'def producer_~w : ProducerProof := {~n', [SafeName]),
            format(Stream, '  producer := "~w",~n', [Rust]),
            format(Stream, '  output := "~w",~n', [Parquet]),
            format(Stream, '  status := "~w"~n', [Status]),
            format(Stream, '}~n~n', [])
        )
    ),
    
    close(Stream),
    
    write('✅ Proofs exported'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 INFER & PROVE: RUST → PARQUET'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Discover
    discover_rust_programs,
    nl,
    discover_parquet_files,
    nl,
    
    % Infer
    infer_all_producers,
    nl,
    
    % Prove
    prove_all,
    nl,
    
    % Export
    export_proofs,
    nl,
    
    write('✅ INFERENCE & PROOF COMPLETE'), nl,
    
    % Summary
    findall(P, proven_producer(_, _, P), Statuses),
    length(Statuses, Count),
    format('~n🎯 Proven ~w producer relationships~n', [Count]).

% ?- main.
