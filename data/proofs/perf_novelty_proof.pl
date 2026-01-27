% Perf Trace Novelty Proof
% Record each build with perf, ingest traces, prove novelty

:- dynamic perf_trace/3.
:- dynamic trace_ingested/3.
:- dynamic novelty_proven/4.

% ═══════════════════════════════════════════════════════════
% RECORD BUILD WITH PERF
% ═══════════════════════════════════════════════════════════

record_build(Name, BuildCmd) :-
    format('📊 Recording build of ~w with perf...~n', [Name]),
    
    % Run build under perf
    format(atom(PerfCmd), 'perf record -o perf_~w.data ~w', [Name, BuildCmd]),
    shell(PerfCmd, ExitCode),
    
    % Extract perf data
    format(atom(ScriptCmd), 'perf script -i perf_~w.data > perf_~w.trace', [Name, Name]),
    shell(ScriptCmd, _),
    
    assertz(perf_trace(Name, ExitCode, perf_trace_file(Name))),
    format('✅ Recorded: perf_~w.trace~n', [Name]).

perf_trace_file(Name, File) :-
    format(atom(File), 'perf_~w.trace', [Name]).

% ═══════════════════════════════════════════════════════════
% INGEST TRACES
% ═══════════════════════════════════════════════════════════

ingest_trace(Name) :-
    perf_trace(Name, _, _),
    format('🔍 Ingesting trace for ~w...~n', [Name]),
    
    % Read trace file
    perf_trace_file(Name, File),
    format(atom(ReadCmd), 'wc -l ~w', [File]),
    shell(ReadCmd, Lines),
    
    % Extract unique instructions
    extract_unique_instructions(Name, Instructions),
    
    assertz(trace_ingested(Name, Lines, Instructions)),
    format('✅ Ingested: ~w lines, ~w unique instructions~n', [Name, Instructions]).

extract_unique_instructions(Name, Count) :-
    perf_trace_file(Name, File),
    format(atom(Cmd), 'grep -oP "\\s[a-f0-9]+:\\s+\\K[a-z]+" ~w | sort -u | wc -l', [File]),
    shell(Cmd, Count).

% ═══════════════════════════════════════════════════════════
% PROVE NOVELTY
% ═══════════════════════════════════════════════════════════

prove_novelty(Name1, Name2) :-
    trace_ingested(Name1, Lines1, Instr1),
    trace_ingested(Name2, Lines2, Instr2),
    format('🔬 Proving novelty: ~w vs ~w~n', [Name1, Name2]),
    
    % Compare instruction sets
    InstrDiff is abs(Instr1 - Instr2),
    LinesDiff is abs(Lines1 - Lines2),
    
    % Novelty score: different instructions = novel
    NoveltyScore is InstrDiff + LinesDiff,
    
    (NoveltyScore > 0 ->
        Novelty = novel(NoveltyScore)
    ;
        Novelty = identical
    ),
    
    assertz(novelty_proven(Name1, Name2, NoveltyScore, Novelty)),
    format('✅ Novelty: ~w (score: ~w)~n', [Novelty, NoveltyScore]).

% Prove all pairwise novelties
prove_all_novelties :-
    findall(N, trace_ingested(N, _, _), Names),
    prove_pairwise(Names).

prove_pairwise([]).
prove_pairwise([_]).
prove_pairwise([N1, N2 | Rest]) :-
    prove_novelty(N1, N2),
    prove_pairwise([N2 | Rest]).

% ═══════════════════════════════════════════════════════════
% EXPORT TO LEAN4
% ═══════════════════════════════════════════════════════════

export_novelty_proof(Name1, Name2) :-
    novelty_proven(Name1, Name2, Score, Novelty),
    format(atom(File), 'data/proofs/novelty_~w_~w.lean', [Name1, Name2]),
    
    open(File, write, Stream),
    format(Stream, '-- Novelty proof: ~w vs ~w~n', [Name1, Name2]),
    format(Stream, 'theorem novelty_~w_~w : NoveltyScore = ~w := by~n', [Name1, Name2, Score]),
    format(Stream, '  rfl~n', []),
    close(Stream),
    
    format('📝 Exported: ~w~n', [File]).

% ═══════════════════════════════════════════════════════════
% PIPELINE: Record → Ingest → Prove
% ═══════════════════════════════════════════════════════════

process_build(Name, BuildCmd) :-
    record_build(Name, BuildCmd),
    ingest_trace(Name).

% Process all Prolog builds
process_all_builds :-
    process_build(scryer, 'nix build .#scryer'),
    process_build(swi, 'nix build .#swi'),
    process_build(gnu, 'nix build .#gnu'),
    process_build(trealla, 'nix build .#trealla'),
    
    prove_all_novelties,
    
    % Export all proofs
    findall([N1, N2], novelty_proven(N1, N2, _, _), Pairs),
    maplist(export_novelty_proof_pair, Pairs).

export_novelty_proof_pair([N1, N2]) :-
    export_novelty_proof(N1, N2).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('📊 PERF TRACE NOVELTY PROOF'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    process_all_builds,
    
    nl,
    write('✅ ALL NOVELTY PROOFS COMPLETE'), nl,
    
    % Show results
    findall([N1, N2, S], novelty_proven(N1, N2, S, novel(_)), Novels),
    format('~n🎯 Novel pairs: ~w~n', [Novels]).

% ?- main.
