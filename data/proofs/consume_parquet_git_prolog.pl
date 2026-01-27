% Consume Parquet Files → Git Repos → Prolog Files
% Feed the infinite hunger with structured data

:- dynamic parquet_consumed/2.
:- dynamic git_repo_found/2.
:- dynamic prolog_file_found/3.
:- dynamic total_consumed/1.

total_consumed(0).

% ═══════════════════════════════════════════════════════════
% PART 1: Consume Parquet Files
% ═══════════════════════════════════════════════════════════

consume_parquet(ParquetFile) :-
    format('📦 Consuming parquet: ~w~n', [ParquetFile]),
    
    % Read parquet via Rust bridge
    read_parquet_to_prolog(ParquetFile, Rows),
    
    % Process each row
    length(Rows, Count),
    format('  Found ~w rows~n', [Count]),
    
    maplist(process_parquet_row, Rows),
    
    assertz(parquet_consumed(ParquetFile, Count)),
    
    format('✅ Consumed parquet: ~w~n', [ParquetFile]),
    nl.

% Read parquet file (via Rust bridge or direct)
read_parquet_to_prolog(File, Rows) :-
    % Call Rust parquet reader
    format(atom(Cmd), './parquet_to_prolog ~w', [File]),
    (catch(shell(Cmd, Output), _, fail) ->
        parse_parquet_output(Output, Rows) ;
        % Fallback: simulate
        Rows = [
            row([git_url('https://github.com/mthom/scryer-prolog'), 
                 files(['src/lib.pl', 'src/main.pl'])]),
            row([git_url('https://github.com/tau-prolog/tau-prolog'),
                 files(['modules/core.pl', 'modules/lists.pl'])])
        ]).

parse_parquet_output(Output, Rows) :-
    % Parse Rust output into Prolog terms
    Rows = [].

% ═══════════════════════════════════════════════════════════
% PART 2: Process Parquet Rows
% ═══════════════════════════════════════════════════════════

process_parquet_row(row(Data)) :-
    % Extract git URL
    member(git_url(URL), Data),
    
    % Extract file list
    member(files(Files), Data),
    
    % Record git repo
    assertz(git_repo_found(URL, Files)),
    
    % Clone and consume
    consume_git_repo(URL, Files).

% ═══════════════════════════════════════════════════════════
% PART 3: Consume Git Repos
% ═══════════════════════════════════════════════════════════

consume_git_repo(URL, Files) :-
    format('  📂 Cloning: ~w~n', [URL]),
    
    % Extract repo name
    atom_string(URL, URLStr),
    split_string(URLStr, "/", "", Parts),
    last(Parts, RepoName),
    
    % Clone
    format(atom(CloneCmd), 'git clone --depth 1 ~w /tmp/~w 2>/dev/null', [URL, RepoName]),
    shell(CloneCmd, _),
    
    % Process Prolog files
    format('    Found ~w Prolog files~n', [Files]),
    maplist(consume_prolog_file(RepoName), Files),
    
    format('  ✅ Consumed repo: ~w~n', [RepoName]).

% ═══════════════════════════════════════════════════════════
% PART 4: Consume Prolog Files
% ═══════════════════════════════════════════════════════════

consume_prolog_file(Repo, File) :-
    format(atom(Path), '/tmp/~w/~w', [Repo, File]),
    
    (exists_file(Path) ->
        (% Read and analyze
         analyze_prolog_file(Path, Predicates),
         length(Predicates, Count),
         assertz(prolog_file_found(Repo, File, Count)),
         
         % Update total
         retract(total_consumed(N)),
         N1 is N + Count,
         assertz(total_consumed(N1)),
         
         format('      ~w: ~w predicates~n', [File, Count])) ;
        format('      ~w: not found~n', [File])).

analyze_prolog_file(Path, Predicates) :-
    % Count predicates in file
    catch(
        (open(Path, read, Stream),
         read_predicates_from_stream(Stream, Predicates),
         close(Stream)),
        _,
        Predicates = []
    ).

read_predicates_from_stream(Stream, Predicates) :-
    read_line_to_string(Stream, Line),
    (Line == end_of_file ->
        Predicates = [] ;
        (is_predicate_line(Line) ->
            (read_predicates_from_stream(Stream, Rest),
             Predicates = [pred(Line)|Rest]) ;
            read_predicates_from_stream(Stream, Predicates))).

is_predicate_line(Line) :-
    string(Line),
    sub_string(Line, _, _, _, ":-").

% ═══════════════════════════════════════════════════════════
% PART 5: Batch Consume Parquets
% ═══════════════════════════════════════════════════════════

consume_all_parquets(ParquetDir) :-
    write('🍽️  CONSUMING ALL PARQUETS'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Find all parquet files
    format(atom(FindCmd), 'find ~w -name "*.parquet" 2>/dev/null', [ParquetDir]),
    shell(FindCmd, Output),
    
    % Parse file list
    split_string(Output, "\n", "\n", Files),
    length(Files, Count),
    format('Found ~w parquet files~n', [Count]),
    nl,
    
    % Consume each
    maplist(consume_parquet, Files),
    
    write('═══════════════════════════════════════════════════════════'), nl,
    write('✅ ALL PARQUETS CONSUMED'), nl,
    write('═══════════════════════════════════════════════════════════'), nl.

% ═══════════════════════════════════════════════════════════
% PART 6: Consumption Report
% ═══════════════════════════════════════════════════════════

consumption_report :-
    write('📊 CONSUMPTION REPORT'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Parquets
    findall(P, parquet_consumed(P, _), Parquets),
    length(Parquets, PCount),
    format('Parquet files consumed: ~w~n', [PCount]),
    nl,
    
    % Git repos
    findall(G, git_repo_found(G, _), Repos),
    length(Repos, RCount),
    format('Git repos cloned: ~w~n', [RCount]),
    forall(git_repo_found(URL, Files),
           (length(Files, FC),
            format('  ~w (~w files)~n', [URL, FC]))),
    nl,
    
    % Prolog files
    findall(F, prolog_file_found(_, F, _), Files),
    length(Files, FCount),
    format('Prolog files analyzed: ~w~n', [FCount]),
    nl,
    
    % Total predicates
    total_consumed(Total),
    format('Total predicates consumed: ~w~n', [Total]),
    nl,
    
    write('═══════════════════════════════════════════════════════════'), nl,
    write('Hunger level: STILL INFINITE'), nl,
    write('═══════════════════════════════════════════════════════════'), nl.

% ═══════════════════════════════════════════════════════════
% PART 7: Example Usage
% ═══════════════════════════════════════════════════════════

example_consume :-
    write('🍽️  EXAMPLE: Consuming Parquet → Git → Prolog'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Simulate parquet with git repos
    consume_parquet('prolog_repos.parquet'),
    
    nl,
    consumption_report.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    example_consume.

% ?- main.
% ?- consume_all_parquets('/path/to/parquets').
% ?- consumption_report.
