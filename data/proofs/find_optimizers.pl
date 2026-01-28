% find_optimizers.pl - Use plocate to find query optimizer code

:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% PLOCATE SEARCH
% ═══════════════════════════════════════════════════════════

plocate_search(Pattern, Results) :-
    format(atom(Cmd), 'plocate -l 20 "~w" 2>/dev/null', [Pattern]),
    setup_call_cleanup(
        open(pipe(Cmd), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, Results).

% ═══════════════════════════════════════════════════════════
% FIND SPECIFIC TECHNOLOGIES
% ═══════════════════════════════════════════════════════════

find_postgres(Files) :- plocate_search('postgres', Files).
find_mysql(Files) :- plocate_search('mysql', Files).
find_llvm(Files) :- plocate_search('llvm', Files).
find_minizinc(Files) :- plocate_search('minizinc', Files).
find_datafusion(Files) :- plocate_search('datafusion', Files).
find_optimizer(Files) :- plocate_search('optimizer', Files).
find_planner(Files) :- plocate_search('planner', Files).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🔍 FIND OPTIMIZERS - Using plocate~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    find_postgres(PG),
    length(PG, PGCount),
    format('🐘 PostgreSQL: ~w files~n', [PGCount]),
    forall((member(F, PG), sub_string(F, _, _, _, 'optimizer')), 
        format('  ~w~n', [F])),
    
    format('~n🐬 MySQL: ', []),
    find_mysql(MY),
    length(MY, MYCount),
    format('~w files~n', [MYCount]),
    
    format('~n🔧 LLVM: ', []),
    find_llvm(LL),
    length(LL, LLCount),
    format('~w files~n', [LLCount]),
    
    format('~n🧩 MiniZinc: ', []),
    find_minizinc(MZ),
    length(MZ, MZCount),
    format('~w files~n', [MZCount]),
    
    format('~n⚡ DataFusion: ', []),
    find_datafusion(DF),
    length(DF, DFCount),
    format('~w files~n', [DFCount]),
    
    format('~n📊 Optimizer: ', []),
    find_optimizer(OPT),
    length(OPT, OPTCount),
    format('~w files~n', [OPTCount]),
    forall(member(F, OPT), format('  ~w~n', [F])),
    
    format('~n📋 Planner: ', []),
    find_planner(PL),
    length(PL, PLCount),
    format('~w files~n', [PLCount]),
    forall(member(F, PL), format('  ~w~n', [F])),
    
    format('~n✅ COMPLETE~n', []).
