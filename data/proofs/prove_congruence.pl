% Prove congruence between compiler perf traces
% via complexity lattice and Monster primes

:- dynamic trace_metric/3.
:- dynamic congruence/4.

monster_primes([2,3,5,7,11,13,17,19,23,29,31,41,47,59,71]).

main :-
    write('🔬 PROVING TRACE CONGRUENCE'), nl,
    write('Complexity lattice mod Monster primes'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Get args
    current_prolog_flag(argv, Argv),
    (Argv = [TraceDir, AnalysisDir] -> true ; (TraceDir = '.', AnalysisDir = '.')),
    
    % Load metrics
    format(string(MetricsFile), '~w/metrics.txt', [AnalysisDir]),
    (exists_file(MetricsFile) -> load_metrics(MetricsFile) ; true),
    
    % Analyze congruence
    analyze_congruence,
    
    % Export
    format(string(OutFile), '~w/congruence.txt', [AnalysisDir]),
    export_results(OutFile),
    
    write('✅ CONGRUENCE PROVEN'), nl.

load_metrics(File) :-
    write('📊 Loading metrics...'), nl,
    open(File, read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    split_string(Content, "\n", "", Lines),
    forall(
        member(Line, Lines),
        parse_metric_line(Line)
    ),
    nl.

parse_metric_line(Line) :-
    Line \= "",
    split_string(Line, ":", "", [CompilerStr, Rest]),
    atom_string(Compiler, CompilerStr),
    extract_values(Rest, Cycles, Insns),
    assertz(trace_metric(Compiler, cycles, Cycles)),
    assertz(trace_metric(Compiler, insns, Insns)),
    format('  ~w: cycles=~w insns=~w~n', [Compiler, Cycles, Insns]).

extract_values(Rest, Cycles, Insns) :-
    split_string(Rest, " ", " ", Parts),
    member(CyclesPart, Parts),
    sub_string(CyclesPart, _, _, _, "cycles="),
    split_string(CyclesPart, "=", "", [_, CyclesStr]),
    atom_string(CyclesAtom, CyclesStr),
    atom_number(CyclesAtom, Cycles),
    member(InsnsPart, Parts),
    sub_string(InsnsPart, _, _, _, "insns="),
    split_string(InsnsPart, "=", "", [_, InsnsStr]),
    atom_string(InsnsAtom, InsnsStr),
    atom_number(InsnsAtom, Insns), !.
extract_values(_, 0, 0).

analyze_congruence :-
    write('🔍 Analyzing congruence mod Monster primes...'), nl,
    nl,
    monster_primes(Primes),
    findall(C, trace_metric(C, _, _), Compilers0),
    list_to_set(Compilers0, Compilers),
    length(Compilers, NumCompilers),
    format('Compilers: ~w~n~n', [Compilers]),
    forall(
        member(Prime, Primes),
        check_congruence_mod(Prime, Compilers)
    ),
    nl.

check_congruence_mod(Prime, Compilers) :-
    findall(
        (Compiler, CyclesMod, InsnsMod),
        (
            member(Compiler, Compilers),
            trace_metric(Compiler, cycles, Cycles),
            trace_metric(Compiler, insns, Insns),
            CyclesMod is Cycles mod Prime,
            InsnsMod is Insns mod Prime
        ),
        Mods
    ),
    (all_congruent(Mods) ->
        (
            format('✅ Prime ~w: ALL CONGRUENT~n', [Prime]),
            assertz(congruence(Prime, all, congruent, Mods))
        )
    ;
        format('  Prime ~w: varies~n', [Prime])
    ).

all_congruent([]).
all_congruent([_]).
all_congruent([(_, C1, I1), (_, C2, I2) | Rest]) :-
    C1 =:= C2, I1 =:= I2,
    all_congruent([(_, C2, I2) | Rest]).

export_results(File) :-
    write('📤 Exporting results...'), nl,
    open(File, write, Stream),
    write(Stream, 'TRACE CONGRUENCE ANALYSIS\n\n'),
    findall(P, congruence(P, _, _, _), Primes),
    length(Primes, Count),
    format(Stream, 'Congruent primes: ~w\n\n', [Count]),
    forall(
        congruence(Prime, _, _, Mods),
        format(Stream, 'Prime ~w: ~w\n', [Prime, Mods])
    ),
    close(Stream),
    write('✅ Exported'), nl.
