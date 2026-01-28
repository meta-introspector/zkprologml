% Ingest all parquets via reasoning
% Read lists_of_lists, reason about what to ingest, then ingest via Rust oracle

:- dynamic parquet_file/4.
:- dynamic should_ingest/3.
:- dynamic ingested/2.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Read lists_of_lists.parquet via Rust oracle
% ═══════════════════════════════════════════════════════════

discover_parquets :-
    write('🔍 Discovering parquets from lists_of_lists...\n\n'),
    
    % Call Rust to read the meta-parquet
    shell('cargo run --release --bin read_lists_of_lists > parquet_list.txt 2>&1', _),
    
    % Parse the output
    open('parquet_list.txt', read, S),
    read_string(S, _, Content),
    close(S),
    
    % Extract parquet paths (simplified - look for .parquet)
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), sub_string(Line, _, _, _, ".parquet")),
        parse_parquet_line(Line)
    ),
    
    findall(P, parquet_file(P, _, _, _), Parquets),
    length(Parquets, Count),
    format('✅ Found ~w parquet files\n\n', [Count]).

parse_parquet_line(Line) :-
    % Extract path from line
    (sub_string(Line, Start, _, _, "/") ->
        sub_string(Line, Start, _, 0, Path),
        assertz(parquet_file(Path, unknown, 0, unknown))
    ; true).

% ═══════════════════════════════════════════════════════════
% REASON: Decide what to ingest based on patterns
% ═══════════════════════════════════════════════════════════

reason_about_ingestion :-
    write('🧠 Reasoning about what to ingest...\n\n'),
    
    forall(
        parquet_file(Path, Category, Size, Weight),
        reason_for_file(Path, Category, Size, Weight)
    ).

reason_for_file(Path, _, _, _) :-
    % Priority 1: Code-related parquets
    (sub_string(Path, _, _, _, "code") ; 
     sub_string(Path, _, _, _, "source") ;
     sub_string(Path, _, _, _, "rust") ;
     sub_string(Path, _, _, _, "prolog")) ->
    (
        assertz(should_ingest(Path, high, code_related)),
        format('✅ HIGH: ~w (code-related)\n', [Path])
    )
    ;
    % Priority 2: Complexity/Monster related
    (sub_string(Path, _, _, _, "complexity") ;
     sub_string(Path, _, _, _, "monster") ;
     sub_string(Path, _, _, _, "prime")) ->
    (
        assertz(should_ingest(Path, high, complexity_related)),
        format('✅ HIGH: ~w (complexity-related)\n', [Path])
    )
    ;
    % Priority 3: Metadata/index parquets
    (sub_string(Path, _, _, _, "index") ;
     sub_string(Path, _, _, _, "metadata") ;
     sub_string(Path, _, _, _, "list")) ->
    (
        assertz(should_ingest(Path, medium, metadata)),
        format('  MEDIUM: ~w (metadata)\n', [Path])
    )
    ;
    % Priority 4: Everything else
    (
        assertz(should_ingest(Path, low, other)),
        format('  LOW: ~w\n', [Path])
    ).

% ═══════════════════════════════════════════════════════════
% INGEST: Call Rust oracle to actually read the data
% ═══════════════════════════════════════════════════════════

ingest_high_priority :-
    write('\n🔬 Ingesting high priority parquets...\n\n'),
    
    findall(Path, should_ingest(Path, high, _), HighPriority),
    length(HighPriority, Count),
    format('Found ~w high priority files\n\n', [Count]),
    
    forall(
        should_ingest(Path, high, Reason),
        ingest_parquet(Path, Reason)
    ).

ingest_parquet(Path, Reason) :-
    format('📊 Ingesting: ~w (~w)\n', [Path, Reason]),
    
    % Check if file exists
    (exists_file(Path) ->
        (
            % Call Rust oracle to read it
            format(string(Cmd), 'cargo run --release --bin sample_parquet "~w" 2>&1 | head -20', [Path]),
            shell(Cmd, _),
            assertz(ingested(Path, Reason)),
            write('  ✅ Ingested\n\n')
        )
    ;
        write('  ⚠️  File not found\n\n')
    ).

% ═══════════════════════════════════════════════════════════
% ANALYZE: Extract patterns from ingested data
% ═══════════════════════════════════════════════════════════

analyze_ingested :-
    write('🔱 Analyzing ingested data for Monster patterns...\n\n'),
    
    findall(P, ingested(P, _), Ingested),
    length(Ingested, Count),
    format('Analyzed ~w parquets\n', [Count]),
    
    % Group by reason
    findall(R, ingested(_, R), Reasons),
    list_to_set(Reasons, UniqueReasons),
    
    forall(
        member(R, UniqueReasons),
        (
            findall(P, ingested(P, R), Files),
            length(Files, N),
            format('  ~w: ~w files\n', [R, N])
        )
    ).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🌀 PARQUET INGESTION VIA REASONING\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Discover
    discover_parquets,
    
    % Reason
    reason_about_ingestion,
    
    % Ingest high priority
    ingest_high_priority,
    
    % Analyze
    analyze_ingested,
    
    write('\n✅ INGESTION COMPLETE\n').

% ?- main.
