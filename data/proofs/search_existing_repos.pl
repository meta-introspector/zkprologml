% search_existing_repos.pl - Search our existing data for query optimizers

:- consult('lists_of_lists_meta.pl').
:- consult('generated/merged_constants.pl').

% ═══════════════════════════════════════════════════════════
% SEARCH LOCATE_DIGEST FOR REPOS
% ═══════════════════════════════════════════════════════════

search_repos(Pattern) :-
    locate_digest_path(Path),
    format('🔍 Searching locate_digest for: ~w~n', [Pattern]),
    format(atom(Cmd), 'duckdb -c "SELECT * FROM read_parquet(\'~w\') WHERE path LIKE \'%~w%\' LIMIT 20"', [Path, Pattern]),
    shell(Cmd).

% Search for specific technologies
find_postgres :- search_repos('postgres').
find_mysql :- search_repos('mysql').
find_llvm :- search_repos('llvm').
find_minizinc :- search_repos('minizinc').
find_prolog :- search_repos('prolog').
find_lean :- search_repos('lean').
find_optimizer :- search_repos('optim').
find_planner :- search_repos('planner').

% ═══════════════════════════════════════════════════════════
% SEARCH ALL AT ONCE
% ═══════════════════════════════════════════════════════════

search_all :-
    format('~n🔍 SEARCHING EXISTING DATA~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    locate_digest_path(Path),
    
    % Count total files
    format('📊 Total files in locate_digest:~n', []),
    format(atom(CountCmd), 'duckdb -c "SELECT COUNT(*) as total FROM read_parquet(\'~w\')"', [Path]),
    shell(CountCmd),
    
    format('~n🐘 PostgreSQL files:~n', []),
    find_postgres,
    
    format('~n🐬 MySQL files:~n', []),
    find_mysql,
    
    format('~n🔧 LLVM files:~n', []),
    find_llvm,
    
    format('~n🧩 MiniZinc files:~n', []),
    find_minizinc,
    
    format('~n🔮 Prolog files:~n', []),
    find_prolog,
    
    format('~n🎯 Lean files:~n', []),
    find_lean,
    
    format('~n⚡ Optimizer files:~n', []),
    find_optimizer,
    
    format('~n📋 Planner files:~n', []),
    find_planner.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🔍 SEARCH EXISTING REPOS - Use what we have~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    search_all,
    
    format('~n✅ SEARCH COMPLETE~n', []).
