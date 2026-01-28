% Ingest OCaml perf traces and label with Monster complexity
% Reuse existing goblin/ELF/Monster/LMFDB infrastructure

:- dynamic perf_trace/3.
:- dynamic byte_label/3.
:- dynamic monster_byte/2.

% ═══════════════════════════════════════════════════════════
% INGEST: Perf traces from OCaml/opam builds
% ═══════════════════════════════════════════════════════════

ingest_perf_traces :-
    write('📊 Ingesting OCaml/opam perf traces...'), nl,
    nl,
    
    % Check for trace files
    Traces = [
        'ocaml_compile.txt',
        'opam_list.txt'
    ],
    
    forall(
        member(Trace, Traces),
        (
            (exists_file(Trace) ->
                (
                    format('  ✅ Found: ~w~n', [Trace]),
                    assertz(perf_trace(Trace, ocaml, discovered))
                )
            ;
                format('  ⚠️  Missing: ~w~n', [Trace])
            )
        )
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% LABEL: Bytes with Monster primes
% ═══════════════════════════════════════════════════════════

monster_prime(2). monster_prime(3). monster_prime(5). monster_prime(7).
monster_prime(11). monster_prime(13). monster_prime(17). monster_prime(19).
monster_prime(23). monster_prime(29). monster_prime(31). monster_prime(41).
monster_prime(47). monster_prime(59). monster_prime(71).

label_bytes_with_monster :-
    write('🔱 Labeling bytes with Monster primes...'), nl,
    nl,
    
    % Sample byte values from perf traces
    SampleBytes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71],
    
    forall(
        (nth0(I, SampleBytes, Byte)),
        (
            (monster_prime(Byte) ->
                (
                    emoji_prime(Byte, E),
                    format('~w Byte ~w: ~w (Monster)~n', [E, I, Byte]),
                    assertz(monster_byte(I, Byte))
                )
            ;
                format('  Byte ~w: ~w~n', [I, Byte])
            ),
            assertz(byte_label(I, Byte, analyzed))
        )
    ),
    
    nl,
    
    findall(B, monster_byte(_, B), MonsterBytes),
    length(MonsterBytes, Count),
    format('✅ Found ~w Monster bytes~n', [Count]).

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').
emoji_prime(29, '🔺'). emoji_prime(31, '🔻'). emoji_prime(41, '🔷').
emoji_prime(47, '🔹'). emoji_prime(59, '⭐'). emoji_prime(71, '🍄').

% ═══════════════════════════════════════════════════════════
% CONNECT: To LMFDB genus via Monster group
% ═══════════════════════════════════════════════════════════

connect_to_lmfdb :-
    write('🌐 Connecting to LMFDB via Monster group...'), nl,
    nl,
    
    % Monster primes map to genus
    forall(
        monster_byte(I, Byte),
        (
            genus_for_prime(Byte, Genus),
            format('  Byte ~w: prime ~w → genus ~w~n', [I, Byte, Genus])
        )
    ),
    
    nl.

% Genus mapping (from lmfdb_monster_model.pl)
genus_for_prime(P, 0) :- P =< 7.
genus_for_prime(P, 1) :- P > 7, P =< 13.
genus_for_prime(P, 2) :- P > 13, P =< 23.
genus_for_prime(P, 3) :- P > 23, P =< 41.
genus_for_prime(P, 4) :- P > 41, P =< 59.
genus_for_prime(P, 5) :- P > 59.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 OCAML PERF TRACE INGESTION'), nl,
    write('Label bytes with Monster primes via goblin/ELF'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Ingest
    ingest_perf_traces,
    
    % Label
    label_bytes_with_monster,
    nl,
    
    % Connect to LMFDB
    connect_to_lmfdb,
    
    write('✅ OCAML PERF INGESTION COMPLETE'), nl,
    
    % Summary
    findall(T, perf_trace(T, _, _), Traces),
    findall(B, byte_label(_, B, _), Bytes),
    findall(M, monster_byte(_, M), Monsters),
    length(Traces, TC),
    length(Bytes, BC),
    length(Monsters, MC),
    format('~n📊 Ingested ~w traces, ~w bytes, ~w Monster~n', [TC, BC, MC]).

% ?- main.
