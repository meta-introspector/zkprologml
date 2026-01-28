% scale_to_3m.pl - Process 3M objects from locate_digest.parquet

:- consult('generated/merged_constants.pl').
:- consult('lists_of_lists_meta.pl').

% ═══════════════════════════════════════════════════════════
% STREAM PROCESS 3M FILES
% ═══════════════════════════════════════════════════════════

:- dynamic object_count/1.
:- dynamic shard_count/2.  % shard, count

object_count(0).

process_3m_objects :-
    format('🚀 Processing 3M objects from locate_digest.parquet~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    locate_digest_path(Path),
    format('📊 Source: ~w~n~n', [Path]),
    
    % Stream process with DuckDB
    format('🔄 Streaming objects (batches of 10,000)...~n~n', []),
    
    % Process in batches
    process_batch(0, 10000).

process_batch(Offset, BatchSize) :-
    locate_digest_path(Path),
    
    % Query batch
    format(atom(Cmd), 
        'duckdb -c "SELECT * FROM read_parquet(\'~w\') LIMIT ~w OFFSET ~w" 2>/dev/null',
        [Path, BatchSize, Offset]),
    
    setup_call_cleanup(
        open(pipe(Cmd), read, S),
        (
            read_string(S, _, Output),
            split_string(Output, "\n", "", Lines),
            exclude(=(""), Lines, NonEmpty),
            length(NonEmpty, Count)
        ),
        close(S)
    ),
    
    (   Count > 0 ->
        process_lines(NonEmpty, Offset),
        NextOffset is Offset + BatchSize,
        process_batch(NextOffset, BatchSize)
    ;   true
    ).

process_lines([], _).
process_lines([Line|Rest], BaseOffset) :-
    % Parse line and assign Gödel + shard
    atom_string(Path, Line),
    
    % Calculate Gödel (fast hash)
    atom_codes(Path, Codes),
    sum_list(Codes, Sum),
    Godel is Sum * 2654435761,  % Knuth's multiplicative hash
    
    % Assign shard (mod 71)
    Shard is Godel mod 71,
    
    % Update counts
    retract(object_count(N)),
    N1 is N + 1,
    assertz(object_count(N1)),
    
    (   shard_count(Shard, C) ->
        retract(shard_count(Shard, C)),
        C1 is C + 1,
        assertz(shard_count(Shard, C1))
    ;   assertz(shard_count(Shard, 1))
    ),
    
    % Progress
    (   N1 mod 10000 =:= 0 ->
        format('  Processed: ~w objects~n', [N1])
    ;   true
    ),
    
    process_lines(Rest, BaseOffset).

% ═══════════════════════════════════════════════════════════
% STATISTICS
% ═══════════════════════════════════════════════════════════

show_stats :-
    format('~n📊 STATISTICS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    object_count(Total),
    format('  Total objects: ~w~n', [Total]),
    
    aggregate_all(count, shard_count(_, _), ShardCount),
    format('  Shards used: ~w / 71~n', [ShardCount]),
    
    format('~n  Top 10 shards by count:~n', []),
    findall(C-S, shard_count(S, C), Pairs),
    sort(0, @>=, Pairs, Sorted),
    length(Top10, 10),
    append(Top10, _, Sorted),
    forall(member(Count-Shard, Top10),
        format('    Shard ~w: ~w objects~n', [Shard, Count])).

% ═══════════════════════════════════════════════════════════
% EXPORT TO PARQUET
% ═══════════════════════════════════════════════════════════

export_shards :-
    format('~n💾 Exporting shard distribution...~n', []),
    
    open('generated/3m_shard_distribution.csv', write, S),
    write(S, 'shard,count\n'),
    forall(shard_count(Shard, Count),
        format(S, '~w,~w~n', [Shard, Count])),
    close(S),
    
    format('  ✅ Saved to generated/3m_shard_distribution.csv~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🌊 SCALE TO 3M OBJECTS~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Initialize
    retractall(object_count(_)),
    retractall(shard_count(_, _)),
    assertz(object_count(0)),
    
    % Process
    process_3m_objects,
    
    % Stats
    show_stats,
    
    % Export
    export_shards,
    
    format('~n✅ COMPLETE - Processed 3M objects~n', []).
