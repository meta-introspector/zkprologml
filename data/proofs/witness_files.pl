% witness_files.pl - Witness and analyze millions of files with full spectrum reasoning

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% LOAD ALL KNOWLEDGE
% ═══════════════════════════════════════════════════════════

:- dynamic file_witness/4.      % file, shard, godel, data_url
:- dynamic git_repo/2.          % path, repo_name
:- dynamic known_pattern/3.     % pattern, type, prime

% Load witnessed files (5,277 files we already sharded)
load_witnessed :-
    csv_read_file('generated/all_files_sharded.csv', Rows, []),
    forall(
        (member(Row, Rows), Row =.. [row|[F, S, G, U]], atom(F)),
        assertz(file_witness(F, S, G, U))
    ),
    aggregate_all(count, file_witness(_, _, _, _), C),
    format('  ✅ ~w witnessed files~n', [C]).

% Detect git repos from paths
detect_git_repos :-
    findall(Repo, (
        file_witness(Path, _, _, _),
        atom_string(Path, PathStr),
        sub_string(PathStr, _, _, _, "/"),
        split_string(PathStr, "/", "", Parts),
        member(Part, Parts),
        (sub_string(Part, _, _, _, ".git") ; 
         sub_string(Part, 0, _, _, "repos/") ;
         sub_string(Part, _, _, 0, "-rs") ;
         sub_string(Part, _, _, 0, "-prolog"))
    ), Repos),
    list_to_set(Repos, UniqueRepos),
    forall(member(R, UniqueRepos), assertz(git_repo(R, R))),
    length(UniqueRepos, C),
    format('  ✅ ~w git repos detected~n', [C]).

% Known file patterns
load_patterns :-
    assertz(known_pattern('.rs', rust, 2)),
    assertz(known_pattern('.pl', prolog, 71)),
    assertz(known_pattern('.lean', lean4, 61)),
    assertz(known_pattern('.nix', nix, 23)),
    assertz(known_pattern('.parquet', data, 19)),
    assertz(known_pattern('.csv', data, 19)),
    assertz(known_pattern('.json', data, 17)),
    assertz(known_pattern('.md', docs, 31)),
    assertz(known_pattern('.toml', config, 29)),
    assertz(known_pattern('.sh', shell, 31)),
    format('  ✅ 10 file patterns loaded~n', []).

% ═══════════════════════════════════════════════════════════
% REASONING & ANALYSIS
% ═══════════════════════════════════════════════════════════

% What type is this file?
file_type(Path, Type, Prime) :-
    atom_string(Path, PathStr),
    known_pattern(Ext, Type, Prime),
    sub_string(PathStr, _, _, 0, Ext).

% Which repo is this file in?
file_repo(Path, Repo) :-
    atom_string(Path, PathStr),
    git_repo(Repo, _),
    sub_string(PathStr, _, _, _, Repo).

% Full spectrum analysis
analyze_file(Path) :-
    file_witness(Path, Shard, Godel, DataURL),
    format('~n🔍 File: ~w~n', [Path]),
    format('  Shard: ~w (Hecke)~n', [Shard]),
    format('  Gödel: ~w~n', [Godel]),
    
    (file_type(Path, Type, Prime) ->
        format('  Type: ~w (prime ~w)~n', [Type, Prime])
    ;   format('  Type: unknown~n', [])),
    
    (file_repo(Path, Repo) ->
        format('  Repo: ~w~n', [Repo])
    ;   format('  Repo: none~n', [])),
    
    format('  Data URL: ~w...~n', [DataURL]).

% Quick statistics
quick_stats :-
    format('~n📊 QUICK ANALYSIS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    % Files by type
    format('~nFiles by type:~n', []),
    forall(known_pattern(Ext, Type, Prime), (
        aggregate_all(count, (file_witness(P, _, _, _), file_type(P, Type, _)), Count),
        (Count > 0 -> format('  ~w (~w): ~w files~n', [Type, Prime, Count]) ; true)
    )),
    
    % Files by shard
    format('~nTop 5 shards:~n', []),
    findall(C-S, (
        member(S, [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]),
        aggregate_all(count, file_witness(_, S, _, _), C)
    ), Pairs),
    sort(Pairs, Sorted),
    reverse(Sorted, [C1-S1, C2-S2, C3-S3, C4-S4, C5-S5|_]),
    format('  Shard ~w: ~w files~n', [S1, C1]),
    format('  Shard ~w: ~w files~n', [S2, C2]),
    format('  Shard ~w: ~w files~n', [S3, C3]),
    format('  Shard ~w: ~w files~n', [S4, C4]),
    format('  Shard ~w: ~w files~n', [S5, C5]),
    
    % Total
    aggregate_all(count, file_witness(_, _, _, _), Total),
    format('~nTotal witnessed: ~w files~n', [Total]).

% Join with git repos
join_analysis :-
    format('~n🔗 JOIN ANALYSIS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    findall(Repo-Count, (
        git_repo(Repo, _),
        aggregate_all(count, file_repo(_, Repo), Count),
        Count > 0
    ), RepoCounts),
    
    sort(RepoCounts, Sorted),
    reverse(Sorted, Top),
    
    format('~nTop repos by file count:~n', []),
    forall(member(Count-Repo, Top), 
        format('  ~w: ~w files~n', [Repo, Count])).

% Main
main :-
    format('🌌 WITNESSING FILES - Full Spectrum Analysis~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    format('📦 Loading knowledge...~n', []),
    load_witnessed,
    load_patterns,
    detect_git_repos,
    
    quick_stats,
    join_analysis,
    
    format('~n✨ Full spectrum analysis complete!~n', []),
    format('~nExample queries:~n', []),
    format('  ?- analyze_file(\'./data/proofs/reason_facts.pl\').~n', []),
    format('  ?- file_type(Path, rust, _).~n', []),
    format('  ?- file_repo(Path, \'coq-of-rust\').~n', []).
